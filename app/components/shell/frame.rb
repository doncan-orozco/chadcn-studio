# frozen_string_literal: true

# The app shell: a header with the theme toggle, an optional sidebar (an HTML string from the page) and the main area.
class Components::Shell::Frame < Components::Base
  def initialize(sidebar: nil)
    @sidebar = sidebar
  end

  def view_template(&)
    div(class: "flex min-h-svh flex-col", data: { testid: "shell" }) do
      header(class: "flex h-14 items-center justify-between border-b px-4") do
        a(href: root_path, class: "text-sm font-semibold") { "Chadcn Studio" }
        render Components::Shell::ThemeToggle.new
      end

      div(class: "flex flex-1") do
        aside(class: "w-72 shrink-0 border-r bg-sidebar text-sidebar-foreground", data: { testid: "sidebar" }) { raw safe(@sidebar) } if @sidebar
        main(class: "min-w-0 flex-1", &)
      end
    end
  end
end
