require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the root page loads with the shell and the scheme buttons set the dark class without JS errors" do
    visit root_path

    assert_selector "main#main-content", text: "Chadcn Studio"

    click_on "Dark"

    assert_selector "html.dark"

    click_on "Light"

    assert_selector "html:not(.dark)"
  end

  test "the active color scheme button is pressed" do
    visit root_path
    find(:testid, "theme-dark").click

    assert_selector "[data-testid=theme-dark][aria-pressed=true]"
    assert_selector "[data-testid=theme-light][aria-pressed=false]"
    assert_selector "[data-testid=theme-system][aria-pressed=false]"
  end

  test "a color scheme chosen in another tab moves the pressed button" do
    visit root_path
    execute_script("localStorage.setItem('shadcn-theme', 'dark'); window.dispatchEvent(new StorageEvent('storage', { key: 'shadcn-theme', storageArea: localStorage }))")

    assert_selector "[data-testid=theme-dark][aria-pressed=true]"
    assert_selector "[data-testid=theme-system][aria-pressed=false]"
  end

  test "a stored color scheme is pressed on load and System is pressed by default" do
    visit root_path

    assert_selector "[data-testid=theme-system][aria-pressed=true]"

    execute_script("localStorage.setItem('shadcn-theme', 'dark')")
    visit root_path

    assert_selector "html.dark"
    assert_selector "[data-testid=theme-dark][aria-pressed=true]"
    assert_selector "[data-testid=theme-system][aria-pressed=false]"
  end

  test "the header brand link is at least 24 px tall on every screen of the create path" do
    [ root_path, new_theme_path, edit_theme_path(themes(:zinc)) ].each do |screen|
      visit screen
      brand = find("header a[href='#{root_path}']")
      height = brand.evaluate_script("this.getBoundingClientRect().height")

      assert_operator height, :>=, 24, "brand link on #{screen} is #{height}px tall"
    end
  end

  test "the header Themes link is at least 24 px tall" do
    visit root_path
    height = find("header a", text: "Themes", exact_text: true).evaluate_script("this.getBoundingClientRect().height")

    assert_operator height, :>=, 24, "Themes link is #{height}px tall"
  end
end
