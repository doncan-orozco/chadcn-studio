# frozen_string_literal: true

# Static sample data of the app shell preview page: the sidebar with its groups.
class Previews::Presenter::Shell
  Entry = Data.define(:label, :badge, :active)
  Group = Data.define(:title, :entries)

  GROUPS = [
    Group.new("Platform", [ Entry.new("Playground", nil, true), Entry.new("Models", nil, false), Entry.new("Documentation", "New", false) ].freeze),
    Group.new("Projects", [ Entry.new("Design engineering", nil, false), Entry.new("Sales & marketing", nil, false), Entry.new("Travel", nil, false) ].freeze)
  ].freeze

  def title = "App shell"
  def product = "Acme Inc"
  def product_initial = product.first
  def groups = GROUPS
  def user = "Ada Lovelace"
end
