# frozen_string_literal: true

# Static sample data of the landing preview page.
class Previews::Presenter::Landing
  Feature = Data.define(:title, :description)
  Tier = Data.define(:name, :price, :blurb, :perks, :featured) do
    def cta_label = "Choose #{name}"
  end

  FEATURES = [
    Feature.new("Accessible", "Contrast is checked for every text pair."),
    Feature.new("Themeable", "One primary color becomes a whole palette."),
    Feature.new("Yours", "Copy the theme as CSS and own it.")
  ].freeze

  TIERS = [
    Tier.new("Starter", "$0", "Everything to get going.", [ "3 projects", "Community support" ].freeze, false),
    Tier.new("Team", "$29", "For teams that ship weekly.", [ "Unlimited projects", "Priority support", "Shared themes" ].freeze, true),
    Tier.new("Scale", "$99", "For organizations.", [ "Single sign-on", "Audit log", "Dedicated support" ].freeze, false)
  ].freeze

  def title = "Landing"
  def headline = "Build interfaces people enjoy"
  def tagline = "A calm, accessible design system with every color derived from one idea."
  def features = FEATURES
  def tiers = TIERS
end
