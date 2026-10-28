# frozen_string_literal: true

# A theme's palette, light and dark side by side, one row per variable.
class Themes::Presenter::Show < Core::Presenter::Base
  Row = Data.define(:name, :light, :dark, :light_style, :dark_style)

  def rows
    @rows ||= (Chadcn::Theme::REQUIRED + Chadcn::Theme::ROOT_ONLY).map do |variable|
      Row.new(name: "--#{variable}", light: light[variable], dark: dark[variable], light_style: swatch_style(light[variable]), dark_style: swatch_style(dark[variable]))
    end
  end

  def title = name
  def summary = "#{published? ? 'Published' : 'Draft'} theme, #{rows.size} variables."

  private

  # `radius` and any other non-color value has no swatch.
  def swatch_style(value)
    "background-color: #{Themes::Oklch.parse(value)}"
  rescue Themes::Oklch::Invalid
    nil
  end
end
