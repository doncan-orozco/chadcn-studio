require "test_helper"

class Views::Layouts::ApplicationTest < ActionDispatch::IntegrationTest
  test "the toaster sizes its close button to 24 px on the button itself" do
    get edit_theme_path(themes(:slate))
    options = JSON.parse(css_select("#toaster").first["data-chadcn--sonner-toast-options-value"])

    assert_includes options.dig("classNames", "closeButton").split, "size-6!"
  end
end
