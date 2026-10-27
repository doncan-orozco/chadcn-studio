# frozen_string_literal: true

# The app shell: a header with the theme toggle, an optional sidebar (an HTML string from the page) and the main area.
class Components::Shell::Frame < Components::Base
  # `sidebar` is pre-rendered, escaped HTML (`content_for(:sidebar)`); a plain String would be trusted blindly, so it is refused.
  def initialize(sidebar: nil)
    unless sidebar.nil? || sidebar.html_safe?
      raise ArgumentError, "sidebar must be an html_safe buffer (use content_for(:sidebar)), got #{sidebar.class}"
    end

    @sidebar = sidebar
  end

  def view_template(&)
    div(class: "flex min-h-svh flex-col", data: { testid: "shell" }) do
      header(class: "flex h-14 items-center justify-between border-b px-4") do
        a(href: root_path, class: "text-sm font-semibold") { "Chadcn Studio" }
        render Components::Shell::ThemeToggle.new
      end

      div(class: "flex flex-1") do
        aside(class: "w-72 shrink-0 border-r bg-sidebar text-sidebar-foreground", aria: { label: "Sidebar" }, data: { testid: "sidebar" }) { raw safe(@sidebar) } if @sidebar
        main(id: "main-content", class: "min-w-0 flex-1", &)
      end
    end
  end
end
