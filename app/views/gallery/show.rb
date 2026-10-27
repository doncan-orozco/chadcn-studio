# frozen_string_literal: true

# Every component of the gem's catalog under the current theme; the demos come from `Chadcn::Catalog`, never from this app.
class Views::Gallery::Show < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto flex max-w-6xl gap-8 p-6") do
      index
      div(class: "min-w-0 flex-1 space-y-10") do
        header do
          h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
          p(class: "text-muted-foreground") { @presenter.summary }
        end
        @presenter.groups.each { |group| group_section(group) }
      end
    end
  end

  private

  def index
    nav(aria: { label: "Components" }, class: "sticky top-6 hidden max-h-[calc(100svh-3rem)] w-48 shrink-0 self-start overflow-y-auto lg:block") do
      ul(class: "space-y-1 text-sm") do
        @presenter.entries.each do |entry|
          li { a(href: @presenter.anchor_href(entry), class: "block rounded-md px-2 py-1 text-muted-foreground hover:bg-accent hover:text-accent-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none") { entry.title } }
        end
      end
    end
  end

  def group_section(group)
    section(aria: { label: group.label }, class: "space-y-6") do
      h2(class: "border-b pb-2 text-sm font-semibold text-muted-foreground") { group.letter }
      group.entries.each { |entry| render Components::Gallery::Entry.new(entry:, anchor: @presenter.anchor(entry), scenario_label: @presenter.scenario_label(entry)) }
    end
  end
end
