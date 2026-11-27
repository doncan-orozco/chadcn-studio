require "test_helper"
require "application_system_test_case"

class EditorSaveQuietTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "Save is quiet while the editor matches the stored theme and loud after an edit" do
    assert_selector "[data-testid=save][data-quiet]"

    quiet = save_background
    fill_in "Name", with: "Renamed"

    assert_no_selector "[data-testid=save][data-quiet]"
    assert_not_equal quiet, save_background
  end

  test "a rejected Save comes back with the default Save" do
    fill_in "Name", with: ""
    page.execute_script("document.getElementById('theme-name').removeAttribute('required')")
    click_on "Save theme"

    assert_selector :testid, "unsaved"
    assert_no_selector "[data-testid=save][data-quiet]"
  end

  private

  def save_background = evaluate_script("getComputedStyle(document.querySelector('[data-testid=save]')).backgroundColor")
end
