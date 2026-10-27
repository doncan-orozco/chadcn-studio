# frozen_string_literal: true

# The gallery page's data: the gem's catalog entries grouped by initial letter, with a stable anchor each.
class Gallery::Presenter::Index
  Group = Data.define(:letter, :label, :entries)

  def initialize(entries: Chadcn::Catalog.entries)
    @entries = entries.sort_by { |entry| entry.title.downcase }
  end

  def title = "Components"
  def count = @entries.size
  def summary = "#{count} components, rendered from the chadcn catalog."
  def entries = @entries
  def anchor(entry) = entry.component
  def anchor_href(entry) = "##{anchor(entry)}"
  def scenario_label(entry) = "#{entry.scenario_count} #{entry.scenario_count == 1 ? 'scenario' : 'scenarios'}"

  def groups
    @groups ||= @entries.group_by { |entry| entry.title[0].upcase }.map do |letter, entries|
      Group.new(letter:, label: "Components starting with #{letter}", entries:)
    end
  end
end
