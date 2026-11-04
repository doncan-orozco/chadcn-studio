# frozen_string_literal: true

# A theme and a prompt -> a pending generation, with its job enqueued (llm-generation R6). No model call happens here.
# `hourly_cap` is the most generations the whole site may start in an hour; nil or any value below 1 turns the check off. The count and the save are not atomic, so a burst can overshoot the cap by a few.
class Generations::Operation::Request < Core::Operation
  CAP_WINDOW = 1.hour
  private_constant :CAP_WINDOW

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
    cap = hourly_cap.to_i
    return false unless cap.positive?

    Generations::Query::InWindow.call({ since: CAP_WINDOW.ago }).count >= cap
  end

  def enqueue(generation)
    @enqueue.call(generation.id)
  rescue StandardError => e
    Rails.logger.error("generation #{generation.id}: enqueue failed: #{e.class}")
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable)
    raise
  end
end
