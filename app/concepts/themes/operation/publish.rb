# frozen_string_literal: true

# Makes the theme's public URL (`/t/<slug>.css`, `.json`) serve it. Publishing again keeps the first publication time.
class Themes::Operation::Publish < Core::Operation
  def call(model:)
    model.published_at ||= Time.current
    model.save or fail_with_model!(model, code: :invalid)

    { model: model }
  end
end
