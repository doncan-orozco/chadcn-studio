# frozen_string_literal: true

# Static sample data of the settings preview page.
class Previews::Presenter::Settings
  Section = Data.define(:key, :label, :active)
  Notification = Data.define(:key, :label, :enabled)

  ACTIVE_SECTION = "profile"
  SECTIONS = [ [ "profile", "Profile" ], [ "account", "Account" ], [ "notifications", "Notifications" ], [ "billing", "Billing" ] ].freeze
  NOTIFICATIONS = [
    Notification.new("comments", "Comments", true),
    Notification.new("mentions", "Mentions", true),
    Notification.new("digest", "Weekly digest", false)
  ].freeze

  def title = "Settings"
  def sections = SECTIONS.map { |key, label| Section.new(key, label, key == ACTIVE_SECTION) }
  def display_name = "Ada Lovelace"
  def bio = "Mathematician and first programmer."
  def notifications = NOTIFICATIONS
end
