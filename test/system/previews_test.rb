require "application_system_test_case"

class PreviewsTest < ApplicationSystemTestCase
  Views::Previews::PAGES.each_key do |page|
    %w[light dark].each do |scheme|
      test "#{page} renders in #{scheme} without JS errors" do
        visit preview_path(page)
        click_on scheme.capitalize

        assert_selector :testid, "preview-root"
        assert_selector "h1"
        assert_selector(scheme == "dark" ? "html.dark" : "html:not(.dark)")
      end
    end
  end

  test "settings delete dialog trigger opens an accessible dialog" do
    visit preview_path("settings")
    trigger = find("button", text: "Delete account")

    assert_equal "dialog", trigger["aria-haspopup"]

    trigger.click

    assert_selector "[role=dialog]", text: "Delete your account?"
    assert_predicate trigger["aria-controls"], :present?
  end

  test "shell opens the sidebar sheet on a phone viewport" do
    page.driver.resize(390, 844)
    visit preview_path("shell")
    click_on "Toggle Sidebar"

    assert_selector "[role=dialog]", text: "Playground"
  ensure
    page.driver.resize(1400, 1400)
  end
end
