# frozen_string_literal: true

# A theme as a card of the list: its name, age and a strip of the colors that tell themes apart.
class Themes::Presenter::Card < Core::Presenter::Base
  SWATCHES = %w[primary secondary accent chart-1 chart-2 chart-3 chart-4 chart-5].freeze

  Swatch = Data.define(:name, :style)

  def swatches
    @swatches ||= SWATCHES.map { |name| Swatch.new(name:, style: "background-color: #{Themes::Oklch.parse(light.fetch(name))}") }
  end

  def path = helpers.theme_path(__getobj__)
  def edit_path = helpers.edit_theme_path(__getobj__)
  def created_label = "Created #{created_at.to_date.to_fs(:long)}"
  def status_label = published? ? "Published" : "Draft"
end
