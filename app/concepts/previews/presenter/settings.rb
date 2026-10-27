# frozen_string_literal: true

# Static sample data of the settings preview page.
class Previews::Presenter::Settings
  def title = "Settings"
  def sections = [ [ "profile", "Profile" ], [ "account", "Account" ], [ "notifications", "Notifications" ], [ "billing", "Billing" ] ]
  def active_section = "profile"
  def display_name = "Ada Lovelace"
  def bio = "Mathematician and first programmer."
  def notifications = [ [ "comments", "Comments", true ], [ "mentions", "Mentions", true ], [ "digest", "Weekly digest", false ] ]
end
