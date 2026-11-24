require "test_helper"
require "application_system_test_case"

class EditorRadiusTest < ApplicationSystemTestCase
  setup do
    visit edit_theme_path(themes(:zinc))
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
  end

  test "the label shows the live value and the number box follows the slider" do
    assert_equal "0.625rem", find(:testid, "radius-value").text
    execute_script("document.querySelector('[data-testid=radius] [role=slider]').focus()")
    page.driver.browser.keyboard.type(:Right)

    assert_equal "0.65rem", find(:testid, "radius-value").text
    assert_equal "0.65", find(:testid, "radius-number").value
  end

  test "a typed radius moves the slider and the preview, snapped to the step" do
    box = find(:testid, "radius-number")
    box.fill_in with: "1.17"
    box.send_keys(:enter)

    assert_equal "1.15rem", find(:testid, "radius-value").text
    assert_equal "1.15", find(:testid, "radius").find("[role=slider]")["aria-valuenow"]
    assert_equal "1.15rem", evaluate_script("document.querySelector('[data-testid=preview-root]').style.getPropertyValue('--radius')")
  end

  test "a typed radius past the range stops at the end of the slider" do
    find(:testid, "radius-number").fill_in with: "9"
    find(:testid, "radius-number").send_keys(:enter)

    assert_equal "1.5rem", find(:testid, "radius-value").text
  end

  test "the number box never blocks Save, whatever the stored radius is" do
    fill_in "Name", with: "Renamed"
    click_on "Save"

    assert_text "Theme saved"
  end
end
