# frozen_string_literal: true

# Light/dark switch of the app chrome, backed by the gem's `chadcn--theme` controller (class `.dark` on <html>).
class Components::Shell::ThemeToggle < Components::Base
  def view_template
    span(data: { controller: "chadcn--theme" }) do
      render Chadcn::Button.new(
        variant: "ghost", size: "sm", type: "button", data: { action: "chadcn--theme#toggle", testid: "theme-toggle" }
      ) { "Light / dark" }
    end
  end
end
