require "application_system_test_case"

# With a panel open, the first click on Save theme must save: the field commit that the click's blur sets off (a derivation
# request one frame later) must not cancel or replace the Save.
class EditorSaveWithPanelOpenTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "one click on Save with the Radius panel open saves the typed radius" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    find(:testid, "radius-number").fill_in with: "1"
    click_on_in_same_tick(:testid, "radius-number", "save")

    assert_text "Zinc saved", wait: 10
    assert_equal "1rem", themes(:zinc).reload.inputs["radius"]
  end

  test "one click on Save with the Advanced panel open saves the typed override" do
    find(:testid, "group-advanced").click
    fill_in "override-light-border", with: "#9ca3af"
    click_on_in_same_tick(:id, "override-light-border", "save")

    assert_text "Zinc saved", wait: 10
    assert_equal "oklch(0.714 0.019 261.325)", themes(:zinc).reload.inputs.dig("overrides", "light", "border")
  end

  private

  # What a quick click does: the blur commits the field, and the click follows before the next frame.
  def click_on_in_same_tick(locator_type, locator, save_testid)
    field = locator_type == :id ? "document.getElementById('#{locator}')" : "document.querySelector('[data-testid=#{locator}]')"
    execute_script("var f = #{field}; f.dispatchEvent(new Event('change', { bubbles: true })); document.querySelector('[data-testid=#{save_testid}]').click()")
  end
end
