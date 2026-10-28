# frozen_string_literal: true

class Themes::Operation::Destroy < Core::Operation
  def call(model:)
    model.destroy!

    { model: model }
  end
end
