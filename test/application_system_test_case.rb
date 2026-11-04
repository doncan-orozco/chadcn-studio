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

  # Cuprite's js_errors does not surface Content Security Policy violations: a blocked script or image only fires a
  # securitypolicyviolation event. This listener is installed on every document before its own scripts run and keeps
  # the events in sessionStorage so they survive full navigations; the check in before_teardown fails the test that caused one.
  CSP_STORAGE_KEY = "__cspViolations".freeze
  CSP_LISTENER = <<~JS.freeze
    document.addEventListener("securitypolicyviolation", (event) => {
      try {
        const key = "#{CSP_STORAGE_KEY}"
        const found = JSON.parse(sessionStorage.getItem(key) || "[]")
        found.push({ directive: event.effectiveDirective, blocked: event.blockedURI, document: event.documentURI })
        sessionStorage.setItem(key, JSON.stringify(found))
      } catch (_) {}
    })
  JS

  setup do
    page.driver.browser.evaluate_on_new_document(CSP_LISTENER)
  end

  # before_teardown, not a teardown block: those run after Capybara.reset_sessions!, which discards the page.
  def before_teardown
    assert_no_csp_violations
  ensure
    super
  end

  def csp_violations
    page.evaluate_script(<<~JS)
      (() => { try { return JSON.parse(sessionStorage.getItem("#{CSP_STORAGE_KEY}") || "[]") } catch (_) { return [] } })()
    JS
  end

  def clear_csp_violations
    page.execute_script %(try { sessionStorage.removeItem("#{CSP_STORAGE_KEY}") } catch (_) {})
  end

  def assert_no_csp_violations
    found = csp_violations
    return if found.empty?

    lines = found.map { |v| "#{v['directive']} blocked #{v['blocked']} (on #{v['document']})" }

    flunk "Content Security Policy violated:\n#{lines.join("\n")}"
  end
end
