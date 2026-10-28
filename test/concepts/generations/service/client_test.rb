require "test_helper"

class Generations::Service::ClientTest < ActiveSupport::TestCase
  test "refuses to build a real client under test" do
    assert_raises(ArgumentError) { Generations::Service::Client.new }
  end

  test "the request has the cached system prompt, the schema, low effort and none of the forbidden options" do
    sdk = FakeGenerationClient::Sdk.new
    Generations::Service::Client.new(client: sdk).palette_inputs(prompt: "warm")
    request = sdk.requests.sole

    assert_equal :"claude-opus-5-5", request[:model]
    assert_equal({ type: "ephemeral" }, request[:system_].first[:cache_control])
    assert_equal [ { role: "user", content: "warm" } ], request[:messages]
    assert_equal "low", request[:output_config][:effort]
    assert_equal :json_schema, request[:output_config][:format_][:type]
    assert_empty request.keys & %i[temperature top_p top_k thinking]
    assert_equal "user", request[:messages].last[:role]
  end

  test "an end_turn answer is parsed from the text block, after the thinking block" do
    result = Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new).palette_inputs(prompt: "warm")

    assert_predicate result, :ok?
    assert_equal FakeGenerationClient::INPUTS, result.inputs
  end

  test "a refusal, a truncated answer and bad JSON are results, not exceptions" do
    refused = Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new(stop_reason: :refusal)).palette_inputs(prompt: "x")
    truncated = Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new(stop_reason: :max_tokens)).palette_inputs(prompt: "x")
    garbled = Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new(text: "{nope")).palette_inputs(prompt: "x")

    assert_equal %i[refused truncated unavailable], [ refused.status, truncated.status, garbled.status ]
  end

  test "rate limits and connection errors become Transient for the job to retry" do
    request = { method: "post", url: URI("https://api.anthropic.com") }
    [ Anthropic::Errors::RateLimitError.new(url: request[:url], status: 429, headers: {}, body: nil, request: request, response: nil), Anthropic::Errors::APIConnectionError.new(url: request[:url]) ].each do |error|
      client = Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new(error: error))

      assert_raises(Generations::Transient) { client.palette_inputs(prompt: "x") }
    end
  end

  test "any other API status error is :unavailable" do
    error = Anthropic::Errors::InternalServerError.new(url: URI("https://api.anthropic.com"), status: 500, headers: {}, body: nil, request: {}, response: nil)

    assert_equal :unavailable, Generations::Service::Client.new(client: FakeGenerationClient::Sdk.new(error: error)).palette_inputs(prompt: "x").status
  end
end
