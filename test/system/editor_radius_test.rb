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
    find(:testid, "radius").find("[role=slider]").click
    page.driver.browser.keyboard.type(:Right)

    assert_equal "0.65rem", find(:testid, "radius-value").text
    assert_equal "0.65", find(:testid, "radius-number").value
    assert_equal "0.65rem", find(:testid, "radius").find("[role=slider]")["aria-valuetext"]
  end

  test "typing a radius keeps the focus in the number box" do
    box = find(:testid, "radius-number")
    box.fill_in with: "1"
    box.send_keys(:enter)

    assert_selector :testid, "radius-value", text: "1rem"
    assert_equal "radius-number", evaluate_script("document.activeElement.id")
  end

  test "tabbing out of a typed radius does not pull the focus back to the slider" do
    box = find(:testid, "radius-number")
    box.fill_in with: "1"
    box.send_keys(:tab)

    assert_selector :testid, "radius-value", text: "1rem"
    assert_not_equal "slider", evaluate_script("document.activeElement.getAttribute('role')")
  end

  test "a typed radius moves the slider and the preview, snapped to the step" do
    box = find(:testid, "radius-number")
    box.fill_in with: "1.17"
    box.send_keys(:enter)

    assert_selector :testid, "radius-value", text: "1.15rem"
    assert_equal "1.15", find(:testid, "radius").find("[role=slider]")["aria-valuenow"]
    assert_equal "1.15rem", evaluate_script("document.querySelector('[data-testid=preview-root]').style.getPropertyValue('--radius')")
    assert_equal "1.15rem", find_field("theme[inputs][radius]", type: :hidden, visible: :all).value
  end

  test "a radius being typed shows at once, before Enter or Tab, and the box keeps the typed text" do
    box = find(:testid, "radius-number")
    execute_script("const box = document.getElementById('radius-number'); box.value = ''; box.focus()")
    box.send_keys("1")

    assert_selector :testid, "radius-value", text: "1rem"
    assert_equal "1", find(:testid, "radius").find("[role=slider]")["aria-valuenow"]
    assert_equal "1rem", evaluate_script("document.querySelector('[data-testid=preview-root]').style.getPropertyValue('--radius')")
    assert_equal "1", box.value
  end

  test "typing a radius character by character never rewrites the box" do
    box = find(:testid, "radius-number")
    execute_script("const box = document.getElementById('radius-number'); box.value = ''; box.focus()")
    box.send_keys("0", ".", "7")

    assert_selector :testid, "radius-value", text: "0.7rem"
    assert_equal "0.7", box.value
  end

  test "the Radius row subtitle follows the typed value" do
    execute_script("const box = document.getElementById('radius-number'); box.value = ''; box.focus()")
    find(:testid, "radius-number").send_keys("1")

    assert_selector "#summary-radius", text: "1rem"
  end

  test "an off-step radius being typed keeps its text until the box is left" do
    box = find(:testid, "radius-number")
    execute_script("const box = document.getElementById('radius-number'); box.value = ''; box.focus()")
    box.send_keys("1", ".", "1", "7")

    assert_selector :testid, "radius-value", text: "1.15rem"
    assert_equal "1.17", box.value
    box.send_keys(:tab)

    assert_field "radius-number", with: "1.15"
  end

  test "Enter after typing an off-step radius snaps the box" do
    box = find(:testid, "radius-number")
    execute_script("const box = document.getElementById('radius-number'); box.value = ''; box.focus()")
    box.send_keys("1", ".", "1", "7", :enter)

    assert_selector :testid, "radius-value", text: "1.15rem"
    assert_field "radius-number", with: "1.15"
    assert_equal "radius-number", evaluate_script("document.activeElement.id")
  end

  test "typing the current value changes nothing" do
    box = find(:testid, "radius-number")
    box.send_keys(:up)

    assert_selector :testid, "radius-value", text: "0.65rem"
    box.fill_in with: "0.65"
    box.send_keys(:enter)

    assert_equal "0.65rem", find(:testid, "radius-value").text
    assert_equal "0.65", find(:testid, "radius").find("[role=slider]")["aria-valuenow"]
  end

  test "a typed value just below an off-grid radius lands on it" do
    box = find(:testid, "radius-number")
    box.fill_in with: "0.6"
    box.send_keys(:enter)

    assert_selector :testid, "radius-value", text: "0.6rem"
  end

  test "a typed radius past the range stops at the end of the slider" do
    find(:testid, "radius-number").fill_in with: "9"
    find(:testid, "radius-number").send_keys(:enter)

    assert_selector :testid, "radius-value", text: "1.5rem"
  end

  test "the number box never blocks Save, whatever the stored radius is" do
    fill_in "Name", with: "Renamed"
    click_on "Save theme"

    assert_text "Renamed saved"
  end
end
