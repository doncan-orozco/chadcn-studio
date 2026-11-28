require "test_helper"

class Components::Editor::HitAreaTest < ActiveSupport::TestCase
  test "the hit areas are boxes of the element itself, not ::after overlays" do
    Components::Editor::HitArea.constants.each do |name|
      classes = Components::Editor::HitArea.const_get(name)

      assert_no_match(/after:/, classes, "HitArea::#{name} still draws an ::after box")
    end
  end

  test "the slider thumb, the switch and the dialog close each set a 24 px size" do
    assert_includes Components::Editor::HitArea::THUMB.split, "size-6"
    assert_includes Components::Editor::HitArea::SWITCH.split, "data-[size=default]:h-6"
    assert_includes Components::Editor::HitArea::CLOSE.split, "size-6"
  end
end
