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

  test "home lists existing themes under the buttons, each name linking to its editor" do
    get root_path

    assert_response :success
    assert_select "main h2", text: "Your themes"
    Themes::Query::Recent.call.limit(PagesController::HOME_THEMES).each do |theme|
      assert_select "main ul[aria-label='Your themes'] a[href=?]", edit_theme_path(theme), text: theme.name
    end
  end

  test "home theme links carry a visible focus style" do
    get root_path

    assert_select "main ul[aria-label='Your themes'] a.focus-visible\\:underline"
  end

  test "home lists at most the five newest themes" do
    extras = Array.new(6) { |i| themes(:zinc).dup.tap { |theme| theme.update!(name: "Extra #{i}", slug: "extra-#{i}") } }

    get root_path

    assert_select "main ul[aria-label='Your themes'] li", PagesController::HOME_THEMES
    assert_select "main ul[aria-label='Your themes'] a", text: "Extra 0", count: 0
    extras.last(PagesController::HOME_THEMES).each do |theme|
      assert_select "main ul[aria-label='Your themes'] a[href=?]", edit_theme_path(theme), text: theme.name
    end
  end

  test "home with no themes has no Your themes list" do
    Theme.destroy_all
    get root_path

    assert_response :success
    assert_select "main h2", text: "Your themes", count: 0
  end
end
