# frozen_string_literal: true

# Every component of the gem's catalog under the current theme; the demos come from `Chadcn::Catalog`, never from this app.
class Views::Gallery::Show < Views::Base
  FILTER_ID = "gallery-filter"
  EMPTY = "No component matches"
  FILTER_ACTIONS = "input->editor--variable-filter#filter change->editor--variable-filter#filter keydown.enter->editor--variable-filter#preventSubmit"
  LINK_CLASSES = "block rounded-md px-2 py-1 text-muted-foreground hover:bg-accent hover:text-accent-foreground " \
                 "focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none " \
                 "aria-[current=location]:bg-accent aria-[current=location]:font-medium aria-[current=location]:text-accent-foreground"
  private_constant :FILTER_ID, :EMPTY, :FILTER_ACTIONS, :LINK_CLASSES

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto flex max-w-6xl gap-8 p-6", data: { controller: "gallery--index-spy" }) do
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
    nav(aria: { label: "Components" }, class: "sticky top-6 hidden max-h-[calc(100svh-3rem)] w-48 shrink-0 self-start overflow-y-auto lg:block",
        data: { controller: "editor--variable-filter", editor__variable_filter_empty_label_value: EMPTY }) do
      index_filter
      @presenter.groups.each { |group| index_group(group) }
    end
  end

  # Typing is not a form edit and Enter must not submit anything: the same field behaviour as the editor's "Find a variable".
  def index_filter
    div(class: "sticky top-0 grid gap-1 bg-background pb-2") do
      render Chadcn::Label.new(html_for: FILTER_ID, class: "text-sm") { "Find a component" }
      render Chadcn::Input.new(
        id: FILTER_ID, type: "search", placeholder: "button, dialog...", autocomplete: "off", spellcheck: "false",
        data: { editor__variable_filter_target: "query", action: FILTER_ACTIONS }
      )
      p(class: "text-xs text-muted-foreground", role: "status", data: { editor__variable_filter_target: "status" })
    end
  end

  def index_group(group)
    section(class: "space-y-1 pb-2") do
      p(class: "px-2 text-xs font-semibold text-muted-foreground", data: { testid: "gallery-index-letter" }) { group.letter }
      ul(class: "space-y-1 text-sm") { group.entries.each { |entry| index_link(entry) } }
    end
  end

  def index_link(entry)
    li(data: { editor__variable_filter_target: "row", variable: entry.title.downcase }) do
      a(href: @presenter.anchor_href(entry), class: LINK_CLASSES, data: { gallery__index_spy_target: "link" }) { entry.title }
    end
  end

  def group_section(group)
    section(aria: { label: group.label }, class: "space-y-6") do
      h2(class: "border-b pb-2 text-sm font-semibold text-muted-foreground") { group.letter }
      group.entries.each { |entry| render Components::Gallery::Entry.new(entry:, anchor: @presenter.anchor(entry), scenario_label: @presenter.scenario_label(entry)) }
    end
  end
end
