# frozen_string_literal: true

# A theme's palette, light and dark side by side, one row per variable; the brand rows come first because they are what people look up.
class Themes::Presenter::Show < Core::Presenter::Base
  Row = Data.define(:name, :label, :light, :dark, :light_style, :dark_style, :light_hex, :dark_hex)

  def rows
    @rows ||= (Chadcn::Theme::REQUIRED + Chadcn::Theme::ROOT_ONLY).map { |variable| row(variable) }
  end

  # [[subheading, rows]]: the brand variables, then every other.
  def sections
    brand, other = rows.partition { |row| Themes::Presenter::Group::BRAND.include?(row.name.delete_prefix("--")) }
    [ [ "Brand", brand ], [ "Everything else", other ] ]
  end

  def title = name
  def edit_path = helpers.edit_theme_path(__getobj__)
  def delete_label = "Delete #{name}"
  def summary = "#{published? ? 'Published' : 'Draft'} theme, #{rows.size} variables."

  private

  def row(variable)
    Row.new(name: "--#{variable}", label: Themes::Presenter::Group.label_for(variable), light: light[variable], dark: dark[variable], light_style: swatch_style(light[variable]),
            dark_style: swatch_style(dark[variable]), light_hex: Themes::Presenter::Group.hex_for(light[variable]), dark_hex: Themes::Presenter::Group.hex_for(dark[variable]))
  end

  # `radius` and any other non-color value has no swatch.
  def swatch_style(value) = Themes::Presenter::Card.swatch_style(value)
end
