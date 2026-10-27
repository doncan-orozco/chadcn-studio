require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the root page loads with the shell and the scheme buttons set the dark class without JS errors" do
    visit root_path

    assert_selector :testid, "shell"

    find(:testid, "theme-dark").click

    assert_selector "html.dark"

    find(:testid, "theme-light").click

    assert_selector "html:not(.dark)"
  end
end
