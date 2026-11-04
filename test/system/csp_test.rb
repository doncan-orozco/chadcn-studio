require "application_system_test_case"

# Proves the collector in ApplicationSystemTestCase: Cuprite's js_errors never surfaces a securitypolicyviolation,
# so without it a blocked resource would pass unseen.
class CspTest < ApplicationSystemTestCase
  test "an inline script the policy blocks is collected and fails the assertion" do
    visit rails_health_check_path
    page.execute_script <<~JS
      const script = document.createElement("script")
      script.textContent = "window.cspProbe = true"
      document.head.appendChild(script)
    JS

    error = assert_raises(Minitest::Assertion) { assert_no_csp_violations }

    assert_includes error.message, "script-src"
    assert_includes error.message, "inline"
    assert_nil page.evaluate_script("window.cspProbe")
    clear_csp_violations
  end

  test "a cross-origin image the policy blocks names its blocked uri" do
    visit rails_health_check_path
    page.execute_script <<~JS
      const image = new Image()
      image.src = "https://csp-probe.invalid/pixel.png"
      document.body.appendChild(image)
    JS

    error = assert_raises(Minitest::Assertion) { assert_no_csp_violations }

    assert_includes error.message, "img-src"
    assert_includes error.message, "https://csp-probe.invalid/pixel.png"
    clear_csp_violations
  end

  test "a violation survives a full page navigation" do
    visit rails_health_check_path
    page.execute_script "const s = document.createElement('script'); s.textContent = '1'; document.head.appendChild(s)"
    visit rails_health_check_path

    assert_raises(Minitest::Assertion) { assert_no_csp_violations }
    clear_csp_violations
  end

  test "a clean page records nothing" do
    visit root_path

    assert_no_csp_violations
  end
end
