require "test_helper"

class Themes::ExportsControllerTest < ActionDispatch::IntegrationTest
  test "a published theme is served as a css attachment that parses into its palette" do
    get theme_export_path("slate", format: "css")

    assert_response :success
    assert_equal "text/css", response.media_type
    assert_match(/attachment; filename="slate\.css"/, response.headers["Content-Disposition"])
    assert_equal themes(:slate).palette, Chadcn::Theme.parse(response.body)
    assert_includes response.body, "/* source: chadcn-studio Slate http://www.example.com/t/slate.css */"
  end

  test "a published theme is served as a json attachment" do
    get theme_export_path("slate", format: "json")

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_match(/attachment; filename="slate\.json"/, response.headers["Content-Disposition"])
    assert_equal "slate", JSON.parse(response.body)["slug"]
  end

  test "an unpublished theme is 404 in both formats" do
    get theme_export_path("zinc", format: "css")

    assert_response :not_found

    get theme_export_path("zinc", format: "json")

    assert_response :not_found
  end

  test "an unknown slug or a missing format is 404" do
    get theme_export_path("nope", format: "css")

    assert_response :not_found

    get "/t/slate"

    assert_response :not_found
  end
end
