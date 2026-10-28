# frozen_string_literal: true

# A theme as a card of the list: its name, age and a strip of the colors that tell themes apart.
class Themes::Presenter::Card < Core::Presenter::Base
  SWATCHES = %w[primary secondary accent chart-1 chart-2 chart-3 chart-4 chart-5].freeze

  Swatch = Data.define(:name, :style)

  # The one place a color becomes a `style` value: re-spelled from a parsed oklch, nil for anything that is not a color.
  def self.swatch_style(value)
    "background-color: #{Themes::Oklch.parse(value)}"
  rescue Themes::Oklch::Invalid
    nil
  end

  # A chip whose stored value is not a color is left out instead of failing the whole list.
  def swatches
    @swatches ||= SWATCHES.filter_map do |name|
      style = self.class.swatch_style(light[name])
      Swatch.new(name:, style:) if style
    end
  end

  def path = helpers.theme_path(__getobj__)
  def edit_path = helpers.edit_theme_path(__getobj__)
  def created_label = "Created #{created_at.to_date.to_fs(:long)}"
  def status_label = published? ? "Published" : "Draft"
  def badge_variant = published? ? "default" : "secondary"
  def edit_label = "Edit #{name}"
end
