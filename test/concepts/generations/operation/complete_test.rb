require "test_helper"
require "turbo/broadcastable/test_helper"

class Generations::Operation::CompleteTest < ActiveSupport::TestCase
  include PaletteAssertions
  include Turbo::Broadcastable::TestHelper

  setup do
    @generation = generations(:pending)
    @theme = @generation.theme
  end

  test "derives, saves the theme and the generation, and tells the editor" do
    client = FakeGenerationClient.new
    result = Generations::Operation::Complete.new(client: client).call(model: @generation)

    assert_predicate result, :success?
    assert_equal [ "A calm theme for a bank" ], client.prompts
    assert_predicate @generation.reload, :completed?
    assert_equal FakeGenerationClient::INPUTS, @generation.inputs
    assert_equal "oklch(0.55 0.2 250)", @theme.reload.inputs["primary"]
    assert_equal "0.5rem", @theme.light["radius"]
    assert_valid_palette @theme.palette
  end

  test "broadcasts the status and a refresh to the theme's stream" do
    assert_turbo_stream_broadcasts(@theme, count: 2) do
      Generations::Operation::Complete.new(client: FakeGenerationClient.new).call(model: @generation)
    end
  end

  test "a refusal fails with :refused and leaves the theme alone" do
    assert_failure FakeGenerationClient.refusing, "refused"
  end

  test "a truncated answer fails with :unavailable" do
    assert_failure FakeGenerationClient.truncated, "unavailable"
  end

  test "inputs the contract rejects fail with :invalid" do
    assert_failure FakeGenerationClient.answering({ "primary" => { "l" => 3, "c" => 0.2, "h" => 10 } }), "invalid"
    assert_failure FakeGenerationClient.answering({ "tint" => 0.1 }), "invalid", generation: generations(:completed).tap { |g| g.update_columns(completed_at: nil) }
  end

  test "a palette that fails strict validation fails with :contrast and does not ask the model again" do
    client = FakeGenerationClient.new
    contrast = Class.new(Core::Operation) { def call(inputs:) = step(Failure(code: :contrast, errors: [ "x" ])) }.new
    result = Generations::Operation::Complete.new(client: client, derive: contrast).call(model: @generation)

    assert_equal :contrast, result.failure[:code]
    assert_equal "contrast", @generation.reload.error_code
    assert_equal 1, client.prompts.size
  end

  test "a generation that already finished is not run again" do
    client = FakeGenerationClient.new
    Generations::Operation::Complete.new(client: client).call(model: generations(:completed))

    assert_empty client.prompts
  end

  test "a transient error propagates so the job can retry" do
    client = FakeGenerationClient.new(error: Generations::Transient.new("rate"))

    assert_raises(Generations::Transient) { Generations::Operation::Complete.new(client: client).call(model: @generation) }
    assert_predicate @generation.reload, :pending?
  end

  private

  def assert_failure(client, code, generation: @generation)
    before = generation.theme.reload.light
    result = Generations::Operation::Complete.new(client: client).call(model: generation)

    assert_equal code.to_sym, result.failure[:code]
    assert_equal code, generation.reload.error_code
    assert_predicate generation, :failed?
    assert_equal before, generation.theme.reload.light
  end
end
