require "test_helper"

class Themes::Presenter::SavedNoticeTest < ActiveSupport::TestCase
  setup { @theme = themes(:zinc) }

  test "nothing changed reads only the saved theme" do
    assert_equal "Zinc saved", notice
  end

  test "a name-only save says what was renamed to what" do
    @theme.name = "Ocean"

    assert_equal "Renamed Zinc to Ocean", notice(after_name: "Ocean")
  end

  test "a rename beside other changes still names the old name" do
    @theme.name = "Ocean"

    assert_equal "Ocean saved: renamed from Zinc, corner radius changed", notice(after_name: "Ocean", after: { "radius" => "1rem" })
  end

  test "inputs are named by the control that moves them, a pin names its mode, an unpin its variable" do
    before = { "overrides" => { "light" => { "ring" => "#111111" } } }
    after = { "radius" => "1rem", "tint" => 0.7, "overrides" => { "light" => { "border" => "#9ca3af" } } }

    assert_equal "Zinc saved: backgrounds and cards tinted, corner radius changed, borders pinned (light mode), 1 more", notice(before: before, after: after)
  end

  test "a variable pinned in both modes names no mode" do
    assert_equal "Zinc saved: borders pinned", notice(after: { "overrides" => { "light" => { "border" => "#9ca3af" }, "dark" => { "border" => "#111111" } } })
  end

  test "an unpin names the variable" do
    assert_equal "Zinc saved: focus ring unpinned (light mode)", notice(before: { "overrides" => { "light" => { "ring" => "#111111" } } })
  end

  test "an unpin in one mode names that mode" do
    before = { "overrides" => { "light" => { "border" => "#9ca3af" }, "dark" => { "border" => "#111111" } } }

    assert_equal "Zinc saved: borders unpinned (light mode)", notice(before: before, after: { "overrides" => { "dark" => { "border" => "#111111" } } })
  end

  test "a re-pin in light and a release in dark name each mode" do
    before = { "overrides" => { "light" => { "border" => "#9ca3af" }, "dark" => { "border" => "#111111" } } }
    after = { "overrides" => { "light" => { "border" => "#222222" } } }

    assert_equal "Zinc saved: borders pinned (light mode), borders unpinned (dark mode)", notice(before: before, after: after)
  end

  test "an input posted back at its default is not named" do
    assert_equal "Zinc saved: corner radius changed", notice(before: { "tint" => "0.4" }, after: { "tint" => 0.4, "radius" => "1rem" })
  end

  private

  def notice(before: {}, after: {}, after_name: "Zinc")
    changes = Themes::Service::Changes.between(before: { name: "Zinc", inputs: before }, after: { name: after_name, inputs: after })
    Themes::Presenter::SavedNotice.new(@theme, changes: changes).to_s
  end
end
