require "test_helper"

class Themes::Service::ChangesTest < ActiveSupport::TestCase
  test "nothing moved is empty" do
    assert_predicate changes({}, {}), :empty?
  end

  test "a rename keeps the old name" do
    assert_equal "Zinc", changes({}, {}, after_name: "Ocean").renamed_from
  end

  test "only the tracked inputs that moved are named" do
    changes = changes({ "primary" => "a", "radius" => "1rem" }, { "primary" => "b", "radius" => "1rem", "tint" => "0.2" })

    assert_equal %w[primary tint], changes.moved_inputs
  end

  test "pinned and unpinned variables are named once across light and dark" do
    before = { "overrides" => { "light" => { "ring" => "x" } } }
    after = { "overrides" => { "light" => { "border" => "y" }, "dark" => { "border" => "z" } } }
    changes = changes(before, after)

    assert_equal %w[border], changes.pinned
    assert_equal %w[ring], changes.unpinned
  end

  test "a changed pin counts as pinned, not unpinned" do
    changes = changes({ "overrides" => { "light" => { "ring" => "x" } } }, { "overrides" => { "light" => { "ring" => "y" } } })

    assert_equal %w[ring], changes.pinned
    assert_empty changes.unpinned
  end

  private

  def changes(before_inputs, after_inputs, after_name: "Zinc")
    Themes::Service::Changes.between(before: { name: "Zinc", inputs: before_inputs }, after: { name: after_name, inputs: after_inputs })
  end
end
