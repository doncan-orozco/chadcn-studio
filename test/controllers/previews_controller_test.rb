require "test_helper"

class PreviewsControllerTest < ActionDispatch::IntegrationTest
  Views::Previews::PAGES.each do |page|
    test "GET /previews/#{page} renders the page inside the preview root" do
      get preview_path(page)

      assert_response :success
      assert_select "[data-testid=preview-root]"
    end
  end

  test "an unknown page is 404" do
    get preview_path("nope")

    assert_response :not_found
  end
end
