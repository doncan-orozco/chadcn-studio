require "test_helper"

class Themes::Presenter::SavedNoticeTest < ActiveSupport::TestCase
  setup { @theme = themes(:zinc) }

  test "nothing changed reads only the saved theme" do
    assert_equal "Zinc saved", notice
  end

  test "a rename names the old name" do
    @theme.name = "Ocean"

    assert_equal "Ocean saved: renamed from Zinc", notice(renamed_from: "Zinc")
  end

  test "changed inputs, pinned and unpinned variables are named" do
    assert_equal "Zinc saved: radius changed, border pinned, ring unpinned", notice(inputs: %w[radius], pinned: %w[border], unpinned: %w[ring])
  end

  test "more than three changes are counted" do
    assert_equal "Zinc saved: renamed from Old, primary changed, tint changed, 1 more", notice(renamed_from: "Old", inputs: %w[primary tint radius])
  end

  private

  def notice(**changes) = Themes::Presenter::SavedNotice.new(@theme, changes: { renamed_from: nil, inputs: [], pinned: [], unpinned: [] }.merge(changes)).to_s
end
