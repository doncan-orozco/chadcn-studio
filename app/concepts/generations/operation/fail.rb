# frozen_string_literal: true

# Marks a generation failed with a code (:refused, :unavailable, :contrast, :invalid) and tells the editor. Idempotent.
class Generations::Operation::Fail < Core::Operation
  CODES = %i[refused unavailable contrast invalid].freeze

  def call(model:, code:)
    raise ArgumentError, "unknown generation failure code: #{code.inspect}" unless CODES.include?(code.to_s.to_sym)

    return { model: model } unless model.pending?

    model.update!(failed_at: Time.current, error_code: code.to_s)
    Generations::Service::Broadcast.status(model)

    { model: model }
  end
end
