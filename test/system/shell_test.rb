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
end
