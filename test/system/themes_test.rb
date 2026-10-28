require "application_system_test_case"

class ThemesTest < ApplicationSystemTestCase
  test "an out-of-range color keeps the form open with the error" do
    visit new_theme_path
    fill_in "Name", with: "Bad"
    fill_in "Primary color", with: "oklch(2 0.2 250)"
    click_on "Create theme"

    assert_selector "#theme-primary-error"
    assert_field "Name", with: "Bad"
  end

  test "the list and the show page render without JS errors in light and dark" do
    %w[light dark].each do |scheme|
      visit themes_path
      click_on scheme.capitalize

      assert_selector :testid, "theme-card", minimum: 1
      assert_selector(scheme == "dark" ? "html.dark" : "html:not(.dark)")
    end

    visit theme_path(themes(:zinc))

    assert_selector :testid, "palette"
  end

  test "deleting a theme from its page returns to the list" do
    visit theme_path(themes(:zinc))
    accept_confirm { click_on "Delete" }

    assert_current_path themes_path
    assert_no_text "Zinc"
  end
end
