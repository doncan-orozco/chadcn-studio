require "test_helper"

class Themes::Presenter::SavedNoticeTest < ActiveSupport::TestCase
  setup do
    @theme = themes(:zinc)
    @before = Themes::Presenter::SavedNotice.snapshot(@theme)
  end

  test "nothing changed reads only the saved theme" do
    assert_equal "Zinc saved", notice
  end

  test "a rename names the old name" do
    @theme.name = "Ocean"

    assert_equal "Ocean saved: renamed from Zinc", notice
  end

  test "a changed input is named" do
    @theme.inputs = @theme.inputs.merge("radius" => "0.9rem")

    assert_equal "Zinc saved: radius changed", notice
  end

  test "a pinned variable is named once, an unpinned one too" do
    @before[:inputs]["overrides"] = { "light" => { "ring" => "oklch(0.6 0.1 30)" } }
    @theme.inputs = @theme.inputs.merge("overrides" => { "light" => { "border" => "oklch(0.7 0.02 260)" }, "dark" => { "border" => "oklch(0.3 0.02 260)" } })

    assert_equal "Zinc saved: border pinned, ring unpinned", notice
  end

  test "more than three changes are counted" do
    @theme.name = "Ocean"
    @theme.inputs = @theme.inputs.merge("primary" => "oklch(0.5 0.2 20)", "tint" => "0.5", "radius" => "1rem")

    assert_equal "Ocean saved: renamed from Zinc, primary changed, tint changed, 1 more", notice
  end

  private

  def notice = Themes::Presenter::SavedNotice.for(@theme, before: @before)
end
