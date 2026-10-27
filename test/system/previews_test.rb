require "application_system_test_case"

class PreviewsTest < ApplicationSystemTestCase
  Views::Previews::PAGES.each do |page|
    %w[light dark].each do |scheme|
      test "#{page} renders in #{scheme} without JS errors" do
        visit preview_path(page)
        click_on scheme.capitalize

        assert_selector "[data-testid=preview-root]"
        assert_selector(scheme == "dark" ? "html.dark" : "html:not(.dark)")
      end
    end
  end
end
