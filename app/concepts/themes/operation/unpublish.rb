# frozen_string_literal: true

# Takes the theme off its public URL; the URL answers 404 again.
class Themes::Operation::Unpublish < Core::Operation
  def call(model:)
    model.published_at = nil
    unless model.save
      model.restore_attributes(%i[published_at])
      fail_with_model!(model, code: :invalid)
    end

    { model: model }
  end
end
