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

  test "from home, a theme created with a hex brand color opens in the editor with that color" do
    visit root_path
    click_on "Create theme"
    fill_in "Name", with: "Acme"
    fill_in "Primary color", with: "#1d4ed8"
    click_on "Create theme"

    assert_text "Theme created"
    assert_selector "#summary-brand", text: Themes::Oklch.parse("oklch(0.488 0.217 264.376)").to_hex
    assert_equal "oklch(0.488 0.217 264.376)", Theme.find_by!(slug: "acme").light["primary"]
  end

  test "the header's Themes link opens the list from home" do
    visit root_path
    within("header") { click_on "Themes" }

    assert_current_path themes_path
    assert_selector :testid, "theme-card", minimum: 1
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

  test "the card's name opens the editor and its Edit button is at least 24 px tall" do
    visit themes_path
    height = evaluate_script("document.querySelector(\"[data-testid=theme-card] a[aria-label^='Edit']\").getBoundingClientRect().height")

    assert_operator height, :>=, 24
    click_on "Zinc"

    assert_current_path edit_theme_path(themes(:zinc))
  end

  test "clicking the card body opens the editor, and the Edit button still works above the stretched link" do
    visit themes_path
    find(:testid, "theme-card", text: "Zinc").click

    assert_current_path edit_theme_path(themes(:zinc))

    visit themes_path
    within(:testid, "theme-card", text: "Zinc") { click_on "Edit" }

    assert_current_path edit_theme_path(themes(:zinc))
  end

  test "clicking the empty footer strip of a card opens the editor" do
    visit themes_path
    find(:testid, "theme-card", text: "Zinc").find("[data-slot=card-footer]").click(x: 0, y: 0)

    assert_current_path edit_theme_path(themes(:zinc))
  end

  test "the Delete button keeps a destructive border in dark mode" do
    visit themes_path
    click_on "Dark"
    visit theme_path(themes(:zinc))

    assert_selector "html.dark"
    border = evaluate_script("getComputedStyle(document.querySelector(\"button[aria-label='Delete Zinc']\")).borderTopColor")
    neutral = evaluate_script("(() => { const probe = document.createElement('div'); probe.className = 'border border-input'; document.body.append(probe); return getComputedStyle(probe).borderTopColor })()")

    refute_equal neutral, border
  end

  test "the show page's main action opens the editor" do
    visit theme_path(themes(:zinc))
    click_on "Preview and edit"

    assert_current_path edit_theme_path(themes(:zinc))
  end

  test "deleting a theme from its page returns to the list" do
    visit theme_path(themes(:zinc))
    accept_confirm { click_on "Delete" }

    assert_current_path themes_path
    assert_no_text "Zinc"
  end
end
