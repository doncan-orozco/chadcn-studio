# frozen_string_literal: true

# A theme as the shadcn `theme.css` colors section: what ui.shadcn.com/themes produces and `chadcn:theme:import` consumes.
# The palette is re-validated by Exports::Service::Servable before this is built (theme-science R12).
class Exports::Presenter::Css < Core::Presenter::Base
  CONTENT_TYPE = "text/css"

  def initialize(theme, base_url:)
    super(theme)
    @base_url = base_url
  end

  def body
    [
      Chadcn::Theme::COLORS_START,
      "/* source: #{comment_text} */",
      Chadcn::Theme.render_colors(palette) + Chadcn::Theme::COLORS_END,
      ""
    ].join("\n")
  end

  def url = "#{@base_url}#{path}"
  def path = helpers.theme_export_path(slug, format: "css")
  # What the studio's download link points at: the public URL once published, the draft export before.
  def download_path = published? ? path : helpers.theme_export_path(slug, format: "css", draft: 1)
  # Always theme.css: the name `chadcn:theme:import` and shadcn use, whatever the theme is called.
  def filename = "theme.css"
  def download_label = "Download #{filename}"
  def downloaded_label = "Downloaded #{filename}"
  def content_type = CONTENT_TYPE
  def import_command = "bin/rails theme:import[#{url}]"

  private

  # One line without comment delimiters, so a theme name cannot close the comment and inject CSS.
  def comment_text = "chadcn-studio #{name} #{url}".gsub(/\s+/, " ").gsub("*/", "* /").gsub("/*", "/ *").strip[0, 200]
end
