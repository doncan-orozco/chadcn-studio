require "test_helper"

class PreviewsControllerTest < ActionDispatch::IntegrationTest
  Views::Previews::PAGES.each_key do |page|
    test "GET /previews/#{page} renders the page inside the preview root with a heading" do
      get preview_path(page)

      assert_response :success
      assert_select "[data-testid=preview-root]"
      assert_select "h1, h2", minimum: 1
    end
  end

  test "settings marks the active section with aria-current" do
    get preview_path("settings")

    assert_select "nav[aria-label=Settings] a[aria-current=page]", count: 1, text: "Profile"
  end

  test "the form fixture names its submit apart from the editor's Save" do
    get preview_path("form")

    assert_select "button", text: "Save", count: 0
    assert_select "button", text: "Create account", count: 1
  end

  test "the shell fixture's sample title is an h2, not the page's h1" do
    get preview_path("shell")

    assert_select "h1", count: 0
    assert_select "[data-testid=app-shell] h2", minimum: 1
  end

  test "an unknown page is 404" do
    get preview_path("nope")

    assert_response :not_found
  end
end
