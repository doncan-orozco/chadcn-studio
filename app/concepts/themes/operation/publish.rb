# frozen_string_literal: true

# Makes the theme's public URL (`/t/<slug>.css`, `.json`) serve it. Publishing again keeps the first publication time.
class Themes::Operation::Publish < Core::Operation
  def call(model:)
    model.published_at ||= Time.current
    unless model.save
      model.restore_attributes(%i[published_at])
      fail_with_model!(model, code: :invalid)
    end

    { model: model }
  end
end
