# frozen_string_literal: true

# Light/dark switch of the app chrome, backed by the gem's `chadcn--theme` controller (class `.dark` on <html>).
class Components::Shell::ThemeToggle < Components::Base
  def view_template
    span(role: "group", aria: { label: "Color scheme" }, data: { controller: "chadcn--theme", testid: "theme-toggle" }) do
      %w[light dark system].each do |mode|
        render Chadcn::Button.new(
          variant: "ghost", size: "sm", type: "button",
          data: { action: "chadcn--theme#set#{mode.capitalize}", testid: "theme-#{mode}" }
        ) { mode.capitalize }
      end
    end
  end
end
