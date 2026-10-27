# frozen_string_literal: true

require "delegate"

class Core::Presenter::Base < SimpleDelegator
  def self.wrap(collection, **context) = collection.map { |item| new(item, **context) }

  private

  def helpers = Rails.application.routes.url_helpers
end
