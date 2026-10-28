require "test_helper"

class Themes::Presenter::CardTest < ActiveSupport::TestCase
  setup { @card = Themes::Presenter::Card.new(themes(:blue)) }

  test "swatches are the primary, secondary, accent and five chart colors, styled from validated oklch" do
    assert_equal Themes::Presenter::Card::SWATCHES, @card.swatches.map(&:name)
    assert_equal "background-color: oklch(0.488 0.243 264.376)", @card.swatches.first.style
  end

  test "a stored value that is not a color never reaches a style attribute" do
    theme = themes(:blue)
    theme.light = theme.light.merge("primary" => "red; background: url(x)")

    assert_raises(Themes::Oklch::Invalid) { Themes::Presenter::Card.new(theme).swatches }
  end

  test "paths, status and date" do
    assert_equal "/themes/#{themes(:blue).id}", @card.path
    assert_equal "/themes/#{themes(:blue).id}/edit", @card.edit_path
    assert_equal "Draft", @card.status_label
    assert_equal "Published", Themes::Presenter::Card.new(themes(:slate)).status_label
    assert_match(/\ACreated \w+ \d+, \d{4}\z/, @card.created_label)
  end
end
