# The stand-ins of the Anthropic API: no test reaches the network or needs a key (llm-generation R10).
class FakeGenerationClient
  Result = Generations::Service::Client::Result

  INPUTS = {
    "primary" => { "l" => 0.55, "c" => 0.2, "h" => 250 }, "tint" => 0.2, "radius_rem" => 0.5,
    "rationale" => "A confident blue with soft corners."
  }.freeze

  attr_reader :prompts

  def initialize(result = Result.new(status: :ok, inputs: INPUTS), error: nil)
    @result = result
    @error = error
    @prompts = []
  end

  def self.refusing = new(Result.new(status: :refused, refusal_category: :general_harms))
  def self.truncated = new(Result.new(status: :truncated))
  def self.answering(inputs) = new(Result.new(status: :ok, inputs: inputs))

  def palette_inputs(prompt:)
    @prompts << prompt
    raise @error if @error

    @result
  end

  # The SDK object under `Generations::Service::Client`: `messages.create` records the request and answers a message.
  class Sdk
    Message = Struct.new(:stop_reason, :stop_details, :content, :usage, keyword_init: true)
    Block = Struct.new(:type, :text)
    Usage = Struct.new(:input_tokens, :output_tokens, :cache_read_input_tokens)

    attr_reader :requests

    def initialize(stop_reason: :end_turn, text: FakeGenerationClient::INPUTS.to_json, error: nil)
      @stop_reason = stop_reason
      @text = text
      @error = error
      @requests = []
    end

    def messages = self

    def create(**request)
      @requests << request
      raise @error if @error

      Message.new(stop_reason: @stop_reason, stop_details: nil, content: [ Block.new(:thinking, "hm"), Block.new(:text, @text) ], usage: Usage.new(10, 20, 0))
    end
  end
end
