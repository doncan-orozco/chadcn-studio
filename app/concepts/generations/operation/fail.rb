# frozen_string_literal: true

# Marks a generation failed with a code (:refused, :unavailable, :contrast, :invalid) and tells the editor. Idempotent.
class Generations::Operation::Fail < Core::Operation
  def call(model:, code:)
    return { model: model } unless model.pending?

    model.update!(failed_at: Time.current, error_code: code.to_s)
    Generations::Service::Broadcast.status(model)

    { model: model }
  end
end
