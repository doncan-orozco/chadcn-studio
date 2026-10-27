require "test_helper"
require "capybara/cuprite"

# `data-testid` is the test attribute of this app: standard finders match it, and `find(:testid, "name")` /
# `assert_selector :testid, "name"` look it up explicitly.
Capybara.test_id = "data-testid"
Capybara.add_selector(:testid) do
  css { |value| "[data-testid='#{value}']" }
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Options go through driven_by: Rails re-registers :cuprite from them on every test, so a Capybara.register_driver
  # block here would be replaced and Ferrum would fall back to its 10s process_timeout.
  driven_by :cuprite, screen_size: [ 1400, 1400 ], options: {
    browser_options: {},
    headless: %w[0 false].exclude?(ENV["HEADLESS"]),
    js_errors: true,
    timeout: 60,
    process_timeout: 60
  }
end
