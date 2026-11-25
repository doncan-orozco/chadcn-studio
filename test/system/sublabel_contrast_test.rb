require "test_helper"
require "application_system_test_case"

class SublabelContrastTest < ApplicationSystemTestCase
  PROBE = "(() => { const probe = document.createElement('i'); probe.style.color = 'var(--sidebar-accent-foreground)'; document.body.append(probe); " \
          "const color = getComputedStyle(probe).color; probe.remove(); return color })()"

  setup do
    visit edit_theme_path(themes(:zinc))
    @muted = color_of("summary-radius")
  end

  test "only the open group's sublabel takes the accent foreground" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    find(:testid, "group-radius-panel").hover # the pointer is off the entry: only the open state can paint it

    assert_equal evaluate_script(PROBE), color_of("summary-radius")
    assert_equal @muted, color_of("summary-surfaces"), "a closed sibling keeps the muted sublabel"
  end

  test "closing the group restores the muted sublabel" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    find(:testid, "group-radius-panel").send_keys(:escape)

    assert_no_selector :testid, "group-radius-panel", visible: :visible
    find("body").hover

    assert_equal @muted, color_of("summary-radius")
  end

  private

  def color_of(id) = evaluate_script("getComputedStyle(document.getElementById('#{id}')).color")
end
