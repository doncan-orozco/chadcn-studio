# frozen_string_literal: true

# Light/dark switch of the app chrome, backed by the gem's `chadcn--theme` controller (class `.dark` on <html>).
class Components::Shell::ThemeToggle < Components::Base
  def view_template
    span(role: "group", aria: { labelledby: "studio-appearance" }, class: "flex items-center gap-1", data: { controller: "chadcn--theme shell--theme-toggle", testid: "theme-toggle" }) do
      span(id: "studio-appearance", class: "mr-1 text-xs text-muted-foreground") { "Studio appearance" }
      %w[light dark system].each do |mode|
        render Chadcn::Button.new(
          variant: "ghost", size: "sm", type: "button", class: "aria-pressed:bg-accent aria-pressed:text-accent-foreground aria-pressed:font-semibold", aria: { pressed: "false" },
          data: { action: "chadcn--theme#set#{mode.capitalize}", shell__theme_toggle_target: "button", mode:, testid: "theme-#{mode}" }
        ) { mode.capitalize }
      end
    end
  end
end
