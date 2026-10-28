# frozen_string_literal: true

# A theme and a prompt -> a pending generation, with its job enqueued (llm-generation R6). No model call happens here.
class Generations::Operation::Request < Core::Operation
  def initialize(enqueue: GenerateThemeJob.method(:perform_later))
    @enqueue = enqueue
    super()
  end

  def call(theme:, prompt:)
    generation = theme.generations.build(prompt: prompt.to_s.strip)
    generation.save or fail_with_model!(generation, code: :invalid)
    @enqueue.call(generation.id)

    { model: generation }
  end
end
