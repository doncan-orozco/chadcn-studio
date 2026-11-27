require "test_helper"

class Themes::Presenter::ShowTest < ActiveSupport::TestCase
  setup { @show = Themes::Presenter::Show.new(themes(:zinc)) }

  test "sections put the brand variables first under their own subheading" do
    brand, other = @show.sections.map(&:rows)

    assert_equal [ "Brand", "Everything else" ], @show.sections.map(&:heading)
    assert_equal %w[--primary --primary-foreground --ring], brand.map(&:name)
    assert_equal Chadcn::Theme::REQUIRED.size + Chadcn::Theme::ROOT_ONLY.size, brand.size + other.size
    assert_empty brand.map(&:name) & other.map(&:name)
  end

  test "rows carry a label and the hex of each color value" do
    primary = @show.sections.flat_map(&:rows).find { |row| row.name == "--primary" }
    radius = @show.sections.flat_map(&:rows).find { |row| row.name == "--radius" }

    assert_equal "Brand color", primary.label
    assert_equal Themes::Oklch.parse(themes(:zinc).light["primary"]).to_hex, primary.light_hex
    assert_nil radius.light_hex
  end
end
