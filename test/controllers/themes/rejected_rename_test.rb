require "test_helper"

class Themes::RejectedRenameTest < ActionDispatch::IntegrationTest
  test "PATCH /themes/:id rejected rename keeps the stored name in the heading and the typed one in the field" do
    patch theme_path(themes(:zinc)), params: { theme: { name: "Forest", inputs: { primary: "oklch(2 0.2 250)" } } }

    assert_response :unprocessable_entity
    assert_select "h1", text: "Edit Zinc"
    assert_select "title", text: "Edit Zinc - Chadcn Studio"
    assert_select "input[name='theme[name]'][value=Forest]"
  end
end
