# frozen_string_literal: true

# Static sample data of the form preview page.
class Previews::Presenter::Form
  Plan = Data.define(:value, :label, :description)

  def title = "Form"
  def roles = [ [ "designer", "Designer" ], [ "engineer", "Engineer" ], [ "manager", "Manager" ] ]
  def plans = [ Plan.new("free", "Free", "For side projects."), Plan.new("pro", "Pro", "For growing teams.") ]
  def email_error = "Enter an email address with an @ in it."
  def volume = [ 40 ]
end
