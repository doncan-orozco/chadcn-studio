require "application_system_test_case"

# With a panel open, the first click on Save theme must save: the field commit that the click's blur sets off (a derivation
# request one frame later) must not cancel or replace the Save.
class EditorSaveWithPanelOpenTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "one click on Save with the Radius panel open saves the stepped radius" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    thumb = find(:testid, "radius").find("[role=slider]")
    execute_script(<<~JS, thumb, find_button("Save theme"))
      const [thumb, save] = arguments
      thumb.focus()
      thumb.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }))
      save.click()
    JS

    assert_text "Zinc saved", wait: 10
    assert_equal "0.65rem", themes(:zinc).reload.inputs["radius"]
  end

  test "one click on Save with the Advanced panel open saves the typed override" do
    find(:testid, "group-advanced").click
    fill_in "override-light-border", with: "#9ca3af"
    change_then_click_within_the_frame("override-light-border", find_button("Save theme"))

    assert_text "Zinc saved", wait: 10
    assert_equal "oklch(0.714 0.019 261.325)", themes(:zinc).reload.inputs.dig("overrides", "light", "border")
  end

  private

  # What a quick click does: the blur commits the field, and the click follows before the next frame (after the microtasks
  # that carry the field's value on to the slider and the hidden inputs).
  def change_then_click_within_the_frame(field_id, button)
    execute_script(<<~JS, field_id, button)
      const [fieldId, button] = arguments
      document.getElementById(fieldId).dispatchEvent(new Event("change", { bubbles: true }))
      const settle = (n) => n === 0 ? Promise.resolve() : Promise.resolve().then(() => settle(n - 1))
      settle(5).then(() => button.click())
    JS
  end
end
