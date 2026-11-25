require "test_helper"
require "application_system_test_case"

class SublabelContrastTest < ApplicationSystemTestCase
  SUBLABEL = "document.getElementById('summary-radius')"
  PROBE = "(() => { const probe = document.createElement('i'); probe.style.color = 'var(--sidebar-accent-foreground)'; document.body.append(probe); " \
          "const color = getComputedStyle(probe).color; probe.remove(); return color })()"

  test "the open group's sublabel takes the accent foreground instead of the muted one" do
    visit edit_theme_path(themes(:zinc))
    muted = evaluate_script("getComputedStyle(#{SUBLABEL}).color")
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    assert_equal evaluate_script(PROBE), evaluate_script("getComputedStyle(#{SUBLABEL}).color")
    assert_not_equal muted, evaluate_script("getComputedStyle(#{SUBLABEL}).color")
  end
end
