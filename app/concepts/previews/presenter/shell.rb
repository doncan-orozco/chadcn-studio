# frozen_string_literal: true

# Static sample data of the app shell preview page: the sidebar with its groups.
class Previews::Presenter::Shell
  Entry = Data.define(:label, :badge)

  def title = "App shell"
  def product = "Acme Inc"
  def platform = [ Entry.new("Playground", nil), Entry.new("Models", nil), Entry.new("Documentation", "New") ]
  def projects = [ Entry.new("Design engineering", nil), Entry.new("Sales & marketing", nil), Entry.new("Travel", nil) ]
  def active = "Playground"
  def user = "Ada Lovelace"
end
