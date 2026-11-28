require "test_helper"

# Target sizes (WCAG 2.2 SC 2.5.8) of a control the edit page draws outside the gem's own sizing: the publication link.
class HitAreasTest < ActionDispatch::IntegrationTest
  setup { get edit_theme_path(themes(:slate)) }

  test "the publication link pads itself to a target over 24 px" do
    assert_select "[data-testid=publication-link].inline-block.py-1"
  end
end
