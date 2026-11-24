require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the active color scheme button is pressed" do
    visit root_path
    find(:testid, "theme-dark").click

    assert_selector "[data-testid=theme-dark][aria-pressed=true]"
    assert_selector "[data-testid=theme-light][aria-pressed=false]"
    assert_selector "[data-testid=theme-system][aria-pressed=false]"
  end
end
