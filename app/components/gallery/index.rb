# frozen_string_literal: true

# The gallery's own table of contents: a filterable, letter-grouped list of links to every catalog entry. The filter is the
# shared list filter with the editor's `variable-filter` controller; the page wrapper mounts `gallery--index-spy`, which marks the link being read.
class Components::Gallery::Index < Components::Base
  FILTER_ID = "gallery-filter"
  EMPTY = "No component matches"
  LINK_CLASSES = "block rounded-md px-2 py-1 text-muted-foreground hover:bg-accent hover:text-accent-foreground " \
                 "focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:outline-none " \
                 "aria-[current=location]:bg-accent aria-[current=location]:font-medium aria-[current=location]:text-accent-foreground"
  private_constant :FILTER_ID, :EMPTY, :LINK_CLASSES

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    nav(aria: { label: "Components" }, class: "sticky top-6 hidden max-h-[calc(100svh-3rem)] w-48 shrink-0 self-start overflow-y-auto lg:block",
        data: { controller: "editor--variable-filter", editor__variable_filter_empty_label_value: EMPTY }) do
      render Components::Shared::ListFilter.new(
        id: FILTER_ID, label: "Find a component", placeholder: "button, dialog...",
        class: "sticky top-0 grid gap-1 bg-background pb-2"
      )
      @presenter.groups.each { |group| group_links(group) }
    end
  end

  private

  def group_links(group)
    section(class: "space-y-1 pb-2") do
      p(class: "px-2 text-xs font-semibold text-muted-foreground", data: { testid: "gallery-index-letter" }) { group.letter }
      ul(class: "space-y-1 text-sm") { group.entries.each { |entry| entry_link(entry) } }
    end
  end

  def entry_link(entry)
    li(data: { editor__variable_filter_target: "row", variable: @presenter.filter_key(entry) }) do
      a(href: @presenter.anchor_href(entry), class: LINK_CLASSES, data: { gallery__index_spy_target: "link" }) { entry.title }
    end
  end
end
