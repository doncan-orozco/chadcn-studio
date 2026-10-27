# frozen_string_literal: true

# Wraps one preview page in the surface the theme variables apply to.
class Components::Previews::Root < Components::Base
  CLASSES = "min-h-full bg-background text-foreground"

  def initialize(page:, **attrs)
    @page = page
    @attrs = attrs
  end

  def view_template
    div(**mix({ class: CLASSES, data: { testid: "preview-root" } }, @attrs)) { render @page }
  end
end
