require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the root page loads with the shell and toggles dark mode without JS errors" do
    visit root_path

    assert_selector :testid, "shell"
    assert_no_selector "html.dark"

    find(:testid, "theme-toggle").click

    assert_selector "html.dark"
  end
end
