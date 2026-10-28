# frozen_string_literal: true

# The native color input of the brand group. `editor--color` converts the picked hex to oklch and announces it.
class Components::Editor::ColorField < Components::Base
  CLASSES = "h-9 w-14 cursor-pointer rounded-md border border-input bg-transparent p-1"

  def initialize(primary:)
    @primary = primary
  end

  def view_template
    div(class: "flex items-center gap-3", data: { controller: "editor--color", editor__color_primary_value: @primary }) do
      render Chadcn::Label.new(html_for: "brand-color") { "Pick a color" }
      input(type: "color", id: "brand-color", class: CLASSES, data: { editor__color_target: "input", action: "change->editor--color#pick", testid: "brand-color" })
    end
  end
end
