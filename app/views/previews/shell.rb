# frozen_string_literal: true

# The app shell: the gem's sidebar with its menu groups. The wrapper contains the sidebar's fixed positioning.
class Views::Previews::Shell < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "relative h-[36rem] overflow-hidden transform-gpu", data: { testid: "app-shell" }) do
      render Chadcn::Sidebar::Provider.new(class: "h-full min-h-0") do
        render Chadcn::Sidebar.new(class: "absolute") do |sidebar|
          sidebar.header do
            div(class: "flex items-center gap-2 px-2 py-1") do
              span(class: "flex size-8 items-center justify-center rounded-md bg-sidebar-primary text-sm font-semibold text-sidebar-primary-foreground") { @presenter.product.first }
              span(class: "font-semibold") { @presenter.product }
            end
          end
          sidebar.content do
            group(sidebar, "Platform", @presenter.platform)
            group(sidebar, "Projects", @presenter.projects)
          end
          sidebar.footer { div(class: "px-2 py-1 text-sm") { @presenter.user } }
          sidebar.rail
        end
        render Chadcn::Sidebar::Inset.new do
          div(class: "space-y-4 p-6") do
            h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
            p(class: "text-muted-foreground") { "The sidebar uses the sidebar-* variables of the theme." }
          end
        end
      end
    end
  end

  private

  def group(sidebar, label, entries)
    sidebar.group do
      sidebar.group_label { label }
      sidebar.menu do
        entries.each do |entry|
          sidebar.menu_item do
            sidebar.menu_button(is_active: entry.label == @presenter.active) { entry.label }
            sidebar.menu_badge { entry.badge } if entry.badge
          end
        end
      end
    end
  end
end
