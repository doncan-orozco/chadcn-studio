require "test_helper"

class Components::Editor::HitAreaTest < ActiveSupport::TestCase
  test "the hit areas are boxes of the element itself, not ::after overlays" do
    Components::Editor::HitArea.constants.each do |name|
      classes = Components::Editor::HitArea.const_get(name)

      assert_no_match(/after:/, classes, "HitArea::#{name} still draws an ::after box")
    end
  end
end
