require "test_helper"

# Target sizes (WCAG 2.2 SC 2.5.8) of two controls the edit page draws outside the gem's own sizing: the publication link
# and the toast close button.
class HitAreasTest < ActionDispatch::IntegrationTest
  setup { get edit_theme_path(themes(:slate)) }

  test "the publication link pads itself to a target over 24 px" do
    assert_select "[data-testid=publication-link].inline-block.py-1"
  end

  test "the toaster widens its close button with a hit box" do
    options = JSON.parse(css_select("#toaster").first["data-chadcn--sonner-toast-options-value"])

    assert_includes options.dig("classNames", "closeButton").split, "after:-inset-1"
  end
end
