require "application_system_test_case"

# With a panel open, the first click on Save theme must save: the field commit that the click's blur sets off (a derivation
# request one frame later) must not cancel or replace the Save.
class EditorSaveWithPanelOpenTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "one click on Save with the Radius panel open saves the stepped radius" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    execute_script(<<~JS)
      var thumb = document.querySelector('[data-testid=radius] [role=slider]');
      thumb.focus();
      thumb.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));
      document.querySelector('[data-testid=save]').click();
    JS

    assert_text "Zinc saved", wait: 10
    assert_equal "0.65rem", themes(:zinc).reload.inputs["radius"]
  end

  test "one click on Save with the Advanced panel open saves the typed override" do
    find(:testid, "group-advanced").click
    fill_in "override-light-border", with: "#9ca3af"
    click_on_in_same_tick(:id, "override-light-border", "save")

    assert_text "Zinc saved", wait: 10
    assert_equal "oklch(0.714 0.019 261.325)", themes(:zinc).reload.inputs.dig("overrides", "light", "border")
  end

  private

  # What a quick click does: the blur commits the field, and the click follows before the next frame (after the microtasks
  # that carry the field's value on to the slider and the hidden inputs).
  def click_on_in_same_tick(locator_type, locator, save_testid)
    field = locator_type == :id ? "document.getElementById('#{locator}')" : "document.querySelector('[data-testid=#{locator}]')"
    execute_script(<<~JS)
      var f = #{field};
      f.dispatchEvent(new Event('change', { bubbles: true }));
      var save = document.querySelector('[data-testid=#{save_testid}]');
      var wait = function (n) { return n === 0 ? Promise.resolve() : Promise.resolve().then(function () { return wait(n - 1) }) };
      wait(5).then(function () { save.click() });
    JS
  end
end
