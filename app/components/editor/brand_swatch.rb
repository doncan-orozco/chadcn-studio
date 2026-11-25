# frozen_string_literal: true

# The brand color as a person knows it: a swatch and its hex, beside the plain-language name.
class Components::Editor::BrandSwatch < Components::Base
  def initialize(group:)
    @group = group
  end

  def view_template
    span(class: "size-4 shrink-0 rounded-full border", style: @group.hex_swatch_style, aria: { hidden: "true" })
    span(class: "font-mono text-foreground", data: { testid: "brand-hex" }) { @group.hex }
  end
end
