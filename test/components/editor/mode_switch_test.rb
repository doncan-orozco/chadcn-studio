require "test_helper"

class Components::Editor::ModeSwitchTest < ActiveSupport::TestCase
  setup { @fragment = Nokogiri::HTML5.fragment(Components::Editor::ModeSwitch.new.call) }

  test "the switch is a 24 px target labelled Dark and named Dark preview" do
    assert @fragment.at_css("div.min-h-6 > label.min-h-6[for=preview-dark]")
    assert_equal "Dark preview", @fragment.at_css("[id=preview-dark]")["aria-label"]
  end

  test "the Dark preview badge is hidden until the switch is checked" do
    badge_class = @fragment.at_css("[data-testid=dark-preview-badge]")["class"]

    assert_includes badge_class, "hidden"
    assert_includes badge_class, "group-has-[[aria-checked=true]]/mode:inline-flex"
  end
end
