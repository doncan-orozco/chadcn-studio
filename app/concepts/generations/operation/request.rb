# frozen_string_literal: true

# A theme and a prompt -> a pending generation, with its job enqueued (llm-generation R6). No model call happens here.
class Generations::Operation::Request < Core::Operation
  def initialize(enqueue: GenerateThemeJob.method(:perform_later))
    @enqueue = enqueue
    super()
  end

  def call(theme:, prompt:)
    generation = theme.generations.build(prompt: prompt.to_s.strip)
    latest = Generations::Query::Latest.call({ theme_id: theme.id }).first
    fail_with_model!(generation, code: :busy) if latest&.pending? && !Generations::Service::Deadline.abandoned?(latest)
    generation.save or fail_with_model!(generation, code: :invalid)
    enqueue(generation)

    { model: generation }
  end

  private

  def enqueue(generation)
    @enqueue.call(generation.id)
  rescue StandardError => e
    Rails.logger.error("generation #{generation.id}: enqueue failed: #{e.class}")
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable)
    raise
  end
end
