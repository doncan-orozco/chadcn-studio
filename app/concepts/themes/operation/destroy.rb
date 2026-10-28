# frozen_string_literal: true

class Themes::Operation::Destroy < Core::Operation
  def call(model:)
    model.destroy or fail_with_model!(model, code: :not_destroyed)

    { model: model }
  end
end
