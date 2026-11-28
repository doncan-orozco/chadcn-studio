require "application_system_test_case"

class ThemesTest < ApplicationSystemTestCase
  test "an out-of-range color keeps the form open with the error" do
    visit new_theme_path
    fill_in "Name", with: "Bad"
    fill_in "Brand color", with: "oklch(2 0.2 250)"
    click_on "Create theme"

    assert_selector "#theme-primary-error"
    assert_field "Name", with: "Bad"
  end

  test "from home, a theme created with a hex brand color opens in the editor with that color" do
    visit root_path
    click_on "Create theme"
    fill_in "Name", with: "Acme"
    fill_in "Brand color", with: "#1d4ed8"
    click_on "Create theme"

    assert_text "Theme created"
    assert_selector "#summary-brand", text: "Blue"
    assert_selector :testid, "brand-hex", text: "#1d4ed8"
    assert_equal "oklch(0.488 0.217 264.376)", Theme.find_by!(slug: "acme").light["primary"]
  end

  test "the Themes list links to describing a theme" do
    GenerateThemeJob.client = FakeGenerationClient.new
    visit themes_path
    click_on "Describe a theme"

    assert_current_path new_theme_path
    assert_field "Describe a theme", disabled: false
  ensure
    GenerateThemeJob.client = nil
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
      choose_appearance scheme

      assert_selector :testid, "theme-card", minimum: 1
      assert_selector(scheme == "dark" ? "html.dark" : "html:not(.dark)")
    end

    visit theme_path(themes(:zinc))

    assert_selector :testid, "palette"
  end

  test "the card's Edit or rename link opens the editor and is at least 24 px tall" do
    visit themes_path
    height = evaluate_script("document.querySelector(\"[data-testid=theme-card] a[aria-label^='Edit or rename']\").getBoundingClientRect().height")

    assert_operator height, :>=, 24
    within(:testid, "theme-card", text: "Zinc") { click_on "Edit or rename" }

    assert_current_path edit_theme_path(themes(:zinc))
  end

  test "the Delete button keeps a destructive border in dark mode" do
    visit themes_path
    choose_appearance "dark"
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
    click_on "Delete"
    confirm_delete("Zinc")

    assert_current_path themes_path
    assert_no_selector :testid, "theme-card", text: "Zinc"
  end

  test "the new theme form marks Name and Brand color as required" do
    visit new_theme_path

    assert_text "* Required"
    assert_selector "label[for='theme-name'] span[aria-hidden='true']", text: "*"
    assert_selector "label[for='theme-primary'] span[aria-hidden='true']", text: "*"
    assert_selector "#theme-name[required]"
    assert_selector "#theme-primary[required]"
  end

  test "a blank name re-renders the form with the error under Name and the color kept" do
    visit new_theme_path
    find(:testid, "new-theme-form").execute_script("this.noValidate = true")
    fill_in "Brand color", with: "#1d4ed8"
    click_on "Create theme"

    assert_selector "#theme-name-error"
    assert_selector "#theme-name[aria-invalid='true']"
    assert_field "Brand color", with: "oklch(0.488 0.217 264.376)"
  end

  test "home's theme rows are links at least 24 px tall and the name carries no underline" do
    visit root_path
    row = "document.querySelector(\"ul[aria-label='Your themes'] a\")"

    assert_operator evaluate_script("#{row}.getBoundingClientRect().height"), :>=, 24
    assert_not_includes evaluate_script("getComputedStyle(#{row}.querySelector('[data-link-name]')).textDecorationLine"), "underline"
  end

  test "home puts the Create theme button above the saved themes, the only default button on the page" do
    visit root_path
    list_top = evaluate_script("document.querySelector(\"ul[aria-label='Your themes']\").getBoundingClientRect().top")
    create_top = evaluate_script("Array.from(document.querySelectorAll('main a')).find(function(a){return a.textContent.trim() === 'Create theme'}).getBoundingClientRect().top")

    assert_operator create_top, :<, list_top
    assert_selector "main a[data-variant=default]", count: 1
  end

  test "a card's title is plain text, not a link" do
    visit themes_path

    assert_no_selector "[data-testid=theme-card] [data-slot=card-title] a"
  end

  test "after a delete the list keeps a status that names the theme" do
    visit theme_path(themes(:zinc))
    click_on "Delete"
    confirm_delete("Zinc")

    assert_selector :testid, "deleted-status", text: "Zinc deleted"
    assert_equal "status", find(:testid, "deleted-status")[:role]
    assert_no_text "Theme deleted" # no toast says it a second time, in other words
    assert_selector :testid, "deleted-status", count: 1

    assert_selector :testid, "deleted-status", text: "Zinc deleted"
  end

  test "a card's Delete button removes that theme from the list" do
    visit themes_path
    within(:testid, "theme-card", text: "Zinc") { find("button[aria-label='Delete Zinc']").click }
    confirm_delete("Zinc")

    assert_current_path themes_path
    assert_no_selector :testid, "theme-card", text: "Zinc"
  end

  test "Delete opens a dialog that names the theme and what is lost" do
    visit theme_path(themes(:zinc))
    click_on "Delete"

    dialog = find("[role=alertdialog]")

    assert_equal "Delete Zinc?", find(id: dialog["aria-labelledby"]).text
    assert_equal "Its 32 variables will be lost. This cannot be undone.", find(id: dialog["aria-describedby"]).text
    assert_equal "Cancel", evaluate_script("document.activeElement.textContent")
    assert_equal "Delete Zinc", dialog.find(:testid, "confirm-delete").text
  end

  test "cancelling the delete dialog keeps the theme" do
    visit theme_path(themes(:zinc))
    click_on "Delete"
    within("[role=alertdialog]") { click_button "Cancel" }

    assert_no_selector "[role=alertdialog]"
    assert_equal "Delete Zinc", evaluate_script("document.activeElement.getAttribute('aria-label')")
    assert_current_path theme_path(themes(:zinc))
    assert Theme.exists?(themes(:zinc).id)
  end

  private

  def confirm_delete(name)
    within("[role=alertdialog]") { click_button "Delete #{name}" }
  end
end
