# frozen_string_literal: true

# Light/dark switch of the app chrome, backed by the gem's `chadcn--theme` controller (class `.dark` on <html>).
class Components::Shell::ThemeToggle < Components::Base
  HINT = "Does not change the theme preview."
  BUTTON_CLASS = "aria-pressed:bg-accent aria-pressed:text-accent-foreground aria-pressed:font-semibold"

  def view_template
    span(role: "group", aria: { labelledby: "studio-appearance", describedby: "studio-appearance-hint" }, class: "flex shrink-0 items-center gap-1", data: { controller: "chadcn--theme shell--theme-toggle", testid: "theme-toggle" }) do
      span(id: "studio-appearance", class: "mr-1 whitespace-nowrap text-xs text-muted-foreground") { "Studio interface" }
      span(id: "studio-appearance-hint", class: "mr-1 hidden whitespace-nowrap text-xs text-muted-foreground lg:inline") { HINT }
      %w[light dark system].each do |mode|
        render Chadcn::Button.new(
          variant: "ghost", size: "sm", type: "button", class: BUTTON_CLASS, aria: { pressed: "false" },
          data: { action: "chadcn--theme#set#{mode.capitalize}", shell__theme_toggle_target: "button", mode:, testid: "theme-#{mode}" }
        ) { mode.capitalize }
      end
    end
  end
end
