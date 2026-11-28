require "test_helper"

class Components::Shell::ThemeToggleTest < ActiveSupport::TestCase
  test "one Studio appearance button opens a menu of Light, Dark and System, and the hint is only a screen-reader description" do
    fragment = Nokogiri::HTML5.fragment(Components::Shell::ThemeToggle.new.call)
    trigger = fragment.at_css("[data-testid=theme-trigger]")

    assert_equal "Studio appearance", trigger.text.strip
    assert_equal "menu", trigger["aria-haspopup"]
    assert_equal "studio-appearance-hint", trigger["aria-describedby"]
    assert_equal Components::Shell::ThemeToggle::HINT, fragment.at_css("#studio-appearance-hint").text
    assert_includes fragment.at_css("#studio-appearance-hint")["class"], "sr-only"
    assert_equal %w[Light Dark System], fragment.css("template [role=menuitemradio]").map { |item| item.text.strip }
    assert_equal 1, fragment.css("button").size
    assert_nil fragment.at_css("[title]")
  end
end
