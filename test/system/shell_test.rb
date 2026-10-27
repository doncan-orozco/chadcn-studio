require "application_system_test_case"

class ShellTest < ApplicationSystemTestCase
  test "the root page loads with the shell and the toggle flips the dark class without JS errors" do
    visit root_path

    assert_selector :testid, "shell"
    assert_selector :testid, "theme-toggle"
    dark = page.evaluate_script("document.documentElement.classList.contains('dark')")

    find(:testid, "theme-toggle").click

    assert_selector(dark ? "html:not(.dark)" : "html.dark")
  end
end
