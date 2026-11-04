# frozen_string_literal: true

# A theme and a prompt -> a pending generation, with its job enqueued (llm-generation R6). No model call happens here.
# `hourly_cap` is the most generations the whole site may start in an hour; nil or 0 turns the check off.
class Generations::Operation::Request < Core::Operation
  CAP_WINDOW = 1.hour

  def initialize(enqueue: GenerateThemeJob.method(:perform_later))
    @enqueue = enqueue
    super()
  end

  def call(theme:, prompt:, hourly_cap: nil)
    generation = theme.generations.build(prompt: prompt.to_s.strip)
    latest = Generations::Query::Latest.call({ theme_id: theme.id }).first
    fail_with_model!(generation, code: :busy) if latest&.pending? && !Generations::Service::Deadline.abandoned?(latest)
    fail_with_model!(generation, code: :capped) if capped?(hourly_cap)
    generation.save or fail_with_model!(generation, code: :invalid)
    enqueue(generation)

    { model: generation }
  end

  private

  def capped?(hourly_cap)
    return false unless hourly_cap.to_i.positive?

    Generations::Query::InWindow.call({ since: CAP_WINDOW.ago }).count >= hourly_cap
  end

  def enqueue(generation)
    @enqueue.call(generation.id)
  rescue StandardError => e
    Rails.logger.error("generation #{generation.id}: enqueue failed: #{e.class}")
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable)
    raise
  end
end
