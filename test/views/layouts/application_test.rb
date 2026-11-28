require "test_helper"

class Views::Layouts::ApplicationTest < ActionDispatch::IntegrationTest
  test "the toaster gives its close button a class of its own, without an ::after overlay" do
    get edit_theme_path(themes(:slate))
    classes = JSON.parse(css_select("#toaster").first["data-chadcn--sonner-toast-options-value"]).dig("classNames", "closeButton")

    assert_predicate classes, :present?
    assert_no_match(/after:/, classes)
  end
end
