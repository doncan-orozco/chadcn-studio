# frozen_string_literal: true

# The brand color as a person holds it: the native color picker and a "Hex" text field beside it. `editor--color` reads what
# was typed or picked and announces it as hex; the server converts it to oklch and remembers the hex (theme-science R6).
class Components::Editor::ColorField < Components::Base
  CLASSES = "h-9 w-14 cursor-pointer rounded-md border border-input bg-transparent p-1"
  HEX_ID = "brand-hex"
  ERROR_ID = "brand-hex-error"

  def initialize(primary:, hex:)
    @primary = primary
    @hex = hex
  end

  def view_template
    div(class: "grid gap-1", data: { controller: "editor--color", editor__color_primary_value: @primary }) do
      div(class: "flex items-center gap-3") do
        render Chadcn::Label.new(html_for: "brand-color") { "Pick a color" }
        input(type: "color", id: "brand-color", class: CLASSES, data: { editor__color_target: "input", action: "change->editor--color#pick", testid: "brand-color" })
        render Chadcn::Label.new(html_for: HEX_ID) { "Hex" }
        hex_field
      end
      p(id: ERROR_ID, role: "alert", hidden: true, class: "text-xs text-destructive", data: { editor__color_target: "error", testid: "brand-hex-error" }) { "Use a hex color such as #0f766e." }
    end
  end

  private

  # Unnamed on purpose: it is not submitted; the controller turns it into the form's primary color.
  def hex_field
    render Chadcn::Input.new(
      id: HEX_ID, default_value: @hex, autocomplete: "off", spellcheck: "false", maxlength: 9, aria: { describedby: ERROR_ID }, class: "h-9 w-28 font-mono text-sm",
      data: { editor__color_target: "hex", action: "change->editor--color#typeHex keydown.enter->editor--color#typeHex:prevent", testid: "brand-hex-field" }
    )
  end
end
