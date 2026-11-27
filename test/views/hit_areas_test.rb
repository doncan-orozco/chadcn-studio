require "test_helper"

# Target sizes of controls the edit page draws outside the gem: the publication link and the toast close button.
class HitAreasTest < ActionDispatch::IntegrationTest
  test "the publication link pads itself to a target over 24 px" do
    get edit_theme_path(themes(:slate))

    assert_select "[data-testid=publication-link].inline-block.py-1"
  end

  test "the toaster gives its close button a 28 px hit box" do
    get edit_theme_path(themes(:slate))

    assert_select "section[aria-live]" do |toaster|
      assert_includes toaster.to_s, "after:-inset-1"
    end
  end
end
