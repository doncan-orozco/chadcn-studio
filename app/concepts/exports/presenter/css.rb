# frozen_string_literal: true

# A theme as the shadcn `theme.css` colors section: what ui.shadcn.com/themes produces and `chadcn:theme:import` consumes.
# `Theme#palette` validated on save (theme-science R12), so this only renders it.
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
  def filename = "#{slug}.css"
  def content_type = CONTENT_TYPE
  def import_command = "bin/rails theme:import[#{url}]"

  private

  # One line without comment delimiters, so a theme name cannot close the comment and inject CSS.
  def comment_text = "chadcn-studio #{name} #{url}".gsub(/\s+/, " ").gsub("*/", "* /").gsub("/*", "/ *").strip[0, 200]
end
