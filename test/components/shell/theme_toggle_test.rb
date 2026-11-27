require "test_helper"

class Components::Shell::ThemeToggleTest < ActiveSupport::TestCase
  test "the group is captioned Studio interface, says it leaves the preview alone, and exposes three pressed-state buttons" do
    fragment = Nokogiri::HTML5.fragment(Components::Shell::ThemeToggle.new.call)

    assert_equal "Studio interface", fragment.at_css("#studio-appearance").text
    assert_equal "studio-appearance", fragment.at_css("[data-testid=theme-toggle]")["aria-labelledby"]
    assert_equal "studio-appearance-hint", fragment.at_css("[data-testid=theme-toggle]")["aria-describedby"]
    assert_equal Components::Shell::ThemeToggle::HINT, fragment.at_css("#studio-appearance-hint").text
    assert_not_includes fragment.at_css("#studio-appearance-hint")["class"], "sr-only"
    assert_includes fragment.at_css("#studio-appearance-hint")["class"], "whitespace-nowrap"
    assert_includes fragment.at_css("#studio-appearance-hint")["class"], "lg:inline"
    assert_nil fragment.at_css("[title]")
    assert_equal 3, fragment.css("button[aria-pressed=false]").size
  end
end
