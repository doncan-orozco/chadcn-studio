# frozen_string_literal: true

# Every component of the gem's catalog under the current theme; the demos come from `Chadcn::Catalog`, never from this app.
class Views::Gallery::Show < Views::Base
  SPY_ACTIONS = "scroll@window->gallery--index-spy#schedule:passive resize@window->gallery--index-spy#schedule:passive"
  private_constant :SPY_ACTIONS

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto flex max-w-6xl gap-8 p-6", data: { controller: "gallery--index-spy", action: SPY_ACTIONS }) do
      render Components::Gallery::Index.new(@presenter)
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

  def group_section(group)
    section(aria: { label: group.label }, class: "space-y-6") do
      h2(class: "border-b pb-2 text-sm font-semibold text-muted-foreground") { group.letter }
      group.entries.each { |entry| render Components::Gallery::Entry.new(entry:, anchor: @presenter.anchor(entry), data: { gallery__index_spy_target: "entry" }) }
    end
  end
end
