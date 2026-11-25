require "test_helper"

class Components::Shell::ThemeToggleTest < ActiveSupport::TestCase
  test "the group is captioned Studio appearance and exposes three pressed-state buttons" do
    fragment = Nokogiri::HTML5.fragment(Components::Shell::ThemeToggle.new.call)

    assert_equal "Studio appearance", fragment.at_css("#studio-appearance").text
    assert_equal "studio-appearance", fragment.at_css("[data-testid=theme-toggle]")["aria-labelledby"]
    assert_equal 3, fragment.css("button[aria-pressed=false]").size
  end
end
