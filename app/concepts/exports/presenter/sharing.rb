# frozen_string_literal: true

# What the editor shows to publish a theme and take it out: the toggle's label and target, the download links and the
# command that imports the public URL.
class Exports::Presenter::Sharing < Core::Presenter::Base
  def initialize(theme, base_url:)
    super(theme)
    @base_url = base_url
  end

  def publication_path = helpers.theme_publication_path(__getobj__)
  def publication_label = published? ? "Unpublish" : "Publish"
  def unpublish? = published?
  def dialog_title = "Export #{name}"
  def css = @css ||= Exports::Presenter::Css.new(__getobj__, base_url: @base_url)
  def json = @json ||= Exports::Presenter::Json.new(__getobj__)
end
