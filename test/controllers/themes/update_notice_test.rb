require "test_helper"

class Themes::UpdateNoticeTest < ActionDispatch::IntegrationTest
  test "PATCH /themes/:id names a pinned variable in the toast" do
    theme = themes(:zinc)
    patch theme_path(theme), params: { theme: { inputs: { overrides: { light: { border: "#9ca3af" } } } } }

    assert_equal "Zinc saved: borders pinned (light mode)", flash[:notice]
  end

  test "PATCH /themes/:id names a changed input and an unpinned variable" do
    theme = themes(:zinc)
    patch theme_path(theme), params: { theme: { inputs: { overrides: { light: { border: "#9ca3af" } } } } }
    patch theme_path(theme), params: { theme: { inputs: { primary: "oklch(0.55 0.2 250)", overrides: { light: { border: "" } } } } }

    assert_equal "Zinc saved: brand color changed, borders unpinned", flash[:notice]
  end
end
