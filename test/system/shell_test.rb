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
end
