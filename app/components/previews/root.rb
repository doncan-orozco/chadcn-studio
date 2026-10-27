# frozen_string_literal: true

# Wraps one preview page in the surface the theme variables apply to.
class Components::Previews::Root < Components::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    div(class: "min-h-full bg-background text-foreground", data: { testid: "preview-root" }) { render @page }
  end
end
