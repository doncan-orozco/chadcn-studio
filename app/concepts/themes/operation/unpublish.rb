# frozen_string_literal: true

# Takes the theme off its public URL; the URL answers 404 again.
class Themes::Operation::Unpublish < Core::Operation
  def call(model:)
    model.published_at = nil
    model.save or fail_with_model!(model, code: :invalid)

    { model: model }
  end
end
