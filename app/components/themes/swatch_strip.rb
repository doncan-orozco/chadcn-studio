# frozen_string_literal: true

# A row of color chips. The `style` of each chip is built by the presenter from validated oklch values.
class Components::Themes::SwatchStrip < Components::Base
  def initialize(swatches:, **attrs)
    @swatches = swatches
    @attrs = attrs
  end

  def view_template
    div(class: "flex h-8 overflow-hidden rounded-md border", **@attrs) do
      @swatches.each { |swatch| span(class: "flex-1", title: swatch.name, style: swatch.style) }
    end
  end
end
