require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the root page loads with the shell and the appearance menu sets the dark class without JS errors" do
    visit root_path

    assert_selector "main#main-content", text: "Chadcn Studio"

    choose_appearance "dark"

    assert_selector "html.dark"

    choose_appearance "light"

    assert_selector "html:not(.dark)"
  end

  test "the appearance menu opens from one Studio appearance button and checks the active scheme" do
    visit root_path

    assert_no_selector "[data-testid=theme-dark]"

    choose_appearance "dark"

    open_appearance_menu

    assert_selector "[data-testid=theme-dark][aria-checked=true]"
    assert_selector "[data-testid=theme-light][aria-checked=false]"
    assert_selector "[data-testid=theme-system][aria-checked=false]"
  end

  test "a color scheme chosen in another tab moves the checked item" do
    visit root_path
    execute_script("localStorage.setItem('shadcn-theme', 'dark'); window.dispatchEvent(new StorageEvent('storage', { key: 'shadcn-theme', storageArea: localStorage }))")

    open_appearance_menu

    assert_selector "[data-testid=theme-dark][aria-checked=true]"
    assert_selector "[data-testid=theme-system][aria-checked=false]"
  end

  test "a stored color scheme is checked on load and System is checked by default" do
    visit root_path
    open_appearance_menu

    assert_selector "[data-testid=theme-system][aria-checked=true]"

    execute_script("localStorage.setItem('shadcn-theme', 'dark')")
    visit root_path

    assert_selector "html.dark"

    open_appearance_menu

    assert_selector "[data-testid=theme-dark][aria-checked=true]"
    assert_selector "[data-testid=theme-system][aria-checked=false]"
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

  test "every theme link on home and on the Themes list is at least 24 px tall" do
    {
      root_path => "main a[href^='/themes/']",
      themes_path => "[data-testid=theme-card] a[href^='/themes/']"
    }.each do |screen, selector|
      visit screen

      assert_selector selector

      all(selector).each do |link|
        height = link.evaluate_script("this.getBoundingClientRect().height")

        assert_operator height, :>=, 24, "#{link.text.inspect} on #{screen} is #{height}px tall"
      end
    end
  end

  test "the header's Components link opens the gallery from home" do
    visit root_path
    within("header nav[aria-label=Main]") { click_on "Components" }

    assert_current_path gallery_path, wait: 15
  end

  private

  def open_appearance_menu
    find(:testid, "theme-trigger").click

    assert_selector "[role=menu]"
  end

  def choose_appearance(mode)
    open_appearance_menu
    find(:testid, "theme-#{mode}").click

    assert_no_selector "[role=menu]"
  end
end
