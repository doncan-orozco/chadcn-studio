require "test_helper"

class Views::Layouts::ApplicationTest < ActionDispatch::IntegrationTest
  test "the toaster restyles its close button on the button itself, not with an ::after overlay" do
    get edit_theme_path(themes(:slate))
    options = JSON.parse(css_select("#toaster").first["data-chadcn--sonner-toast-options-value"])

    assert_predicate options.dig("classNames", "closeButton"), :present?
    assert_no_match(/after:/, options.dig("classNames", "closeButton"))
  end
end
