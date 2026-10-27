# frozen_string_literal: true

# Static sample data of the form preview page.
class Previews::Presenter::Form
  Plan = Data.define(:value, :label, :description) do
    def summary = "#{label}: #{description}"
  end
  Role = Data.define(:value, :label)

  ROLES = [ Role.new("designer", "Designer"), Role.new("engineer", "Engineer"), Role.new("manager", "Manager") ].freeze
  PLANS = [ Plan.new("free", "Free", "For side projects."), Plan.new("pro", "Pro", "For growing teams.") ].freeze

  def title = "Form"
  def roles = ROLES
  def plans = PLANS
  def email_value = "ada.example.com"
  def email_error = "Enter an email address with an @ in it."
  def volume = [ 40 ]
end
