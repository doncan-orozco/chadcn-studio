require "test_helper"

class PreviewsControllerTest < ActionDispatch::IntegrationTest
  Views::Previews::PAGES.each_key do |page|
    test "GET /previews/#{page} renders the page inside the preview root with an h1" do
      get preview_path(page)

      assert_response :success
      assert_select "[data-testid=preview-root]"
      assert_select "h1", minimum: 1
    end
  end

  test "settings marks the active section with aria-current" do
    get preview_path("settings")

    assert_select "nav[aria-label=Settings] a[aria-current=page]", count: 1, text: "Profile"
  end

  test "an unknown page is 404" do
    get preview_path("nope")

    assert_response :not_found
  end
end
