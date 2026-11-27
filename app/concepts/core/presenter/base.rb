# frozen_string_literal: true

class Core::Presenter::Base < SimpleDelegator
  APP_NAME = "Chadcn Studio"

  # The browser tab title of a page: its name, then the app.
  def self.document_title(page) = "#{page} - #{APP_NAME}"
  def self.wrap(collection, **context) = collection.map { |item| new(item, **context) }

  def document_title = self.class.document_title(title)

  private

  def helpers = Rails.application.routes.url_helpers
end
