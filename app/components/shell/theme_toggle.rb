# frozen_string_literal: true

# Light/dark switch of the app chrome, backed by the gem's `chadcn--theme` controller (class `.dark` on <html>).
class Components::Shell::ThemeToggle < Components::Base
  def view_template
    span(role: "group", aria: { label: "Color scheme" }, data: { controller: "chadcn--theme shell--theme-toggle", action: "chadcn--theme:changed->shell--theme-toggle#sync", testid: "theme-toggle" }) do
      %w[light dark system].each do |mode|
        render Chadcn::Button.new(
          variant: "ghost", size: "sm", type: "button", class: "aria-pressed:bg-accent aria-pressed:text-accent-foreground", aria: { pressed: "false" },
          data: { action: "chadcn--theme#set#{mode.capitalize}", shell__theme_toggle_target: "button", mode:, testid: "theme-#{mode}" }
        ) { mode.capitalize }
      end
    end
  end
end
