require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home offers Create theme as its primary action and a way to the themes" do
    get root_path

    assert_response :success
    assert_select "main a[href=?]", new_theme_path, text: "Create theme"
    assert_select "main a[href=?]", themes_path, text: "Browse themes"
  end

  test "the header links to the themes list on every page" do
    [ root_path, themes_path, new_theme_path ].each do |path|
      get path

      assert_select "header nav[aria-label=Main] a[href=?]", themes_path, { text: "Themes" }, path
    end
  end
end
