require "test_helper"

class Themes::Presenter::ShowTest < ActiveSupport::TestCase
  setup { @show = Themes::Presenter::Show.new(themes(:zinc)) }

  test "sections put the brand variables first under their own subheading" do
    (brand_heading, brand), (other_heading, other) = @show.sections

    assert_equal [ "Brand", "Everything else" ], [ brand_heading, other_heading ]
    assert_equal %w[--primary --primary-foreground --ring], brand.map(&:name)
    assert_equal @show.rows.size, brand.size + other.size
    assert_empty brand.map(&:name) & other.map(&:name)
  end

  test "rows carry a label and the hex of each color value" do
    primary = @show.rows.find { |row| row.name == "--primary" }
    radius = @show.rows.find { |row| row.name == "--radius" }

    assert_equal "Brand color", primary.label
    assert_equal Themes::Oklch.parse(themes(:zinc).light["primary"]).to_hex, primary.light_hex
    assert_nil radius.light_hex
  end
end
