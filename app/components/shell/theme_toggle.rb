# frozen_string_literal: true

# The studio's own Light/Dark/System appearance behind one header button, backed by the gem's `chadcn--theme` controller
# (class `.dark` on <html>). The menu content is portaled to <body> by the gem, so the choice reaches the theme controller through
# the menu's `value-change` event (see the Stimulus controller), not through a `data-action` on the items.
class Components::Shell::ThemeToggle < Components::Base
  HINT = "Does not change the theme preview."
  MODES = %w[light dark system].freeze
  ITEM_CLASS = "aria-checked:bg-accent aria-checked:text-accent-foreground aria-checked:font-semibold"

  def view_template
    span(class: "flex shrink-0 items-center", data: { controller: "chadcn--theme shell--theme-toggle", testid: "theme-toggle", action: "chadcn--dropdown-menu:value-change@window->shell--theme-toggle#choose" }) do
      render Chadcn::DropdownMenu.new do |menu|
        menu.trigger(as_child: Chadcn::Button.new(variant: "ghost", size: "sm", aria: { describedby: "studio-appearance-hint" }, data: { testid: "theme-trigger" })) { "Studio appearance" }
        menu.content(align: "end") do
          menu.radio_group(value: nil) do
            MODES.each { |mode| menu.radio_item(value: mode, class: ITEM_CLASS, data: { testid: "theme-#{mode}" }) { mode.capitalize } }
          end
        end
      end
      span(id: "studio-appearance-hint", class: "sr-only") { HINT }
    end
  end
end
