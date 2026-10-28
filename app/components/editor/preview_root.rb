# frozen_string_literal: true

# The ONE element carrying the palette as CSS custom properties and the `.dark` class (design-system R12, phlex R17).
# Preview pages render inside it and nothing of the editor chrome does.
class Components::Editor::PreviewRoot < Components::Base
  CLASSES = "min-h-full bg-background text-foreground"

  def initialize(variables:, **attrs)
    @variables = variables
    @attrs = attrs
  end

  def view_template(&)
    div(**mix({ class: CLASSES, style: style, data: { testid: "preview-root", editor__preview_target: "root" } }, @attrs), &)
  end

  private

  def style = @variables.map { |name, value| "#{name}: #{value};" }.join(" ")
end
