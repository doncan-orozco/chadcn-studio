require "test_helper"

class Themes::Operation::DestroyTest < ActiveSupport::TestCase
  test "removes the theme and its generations" do
    theme = themes(:zinc)
    theme.generations.create!(prompt: "calm") if theme.generations.none?

    assert_difference("Theme.count", -1) { Themes::Operation::Destroy.new.call(model: theme).value! }
    assert_empty Generation.where(theme_id: theme.id)
  end

  test "a refused destroy fails with :not_destroyed" do
    theme = themes(:zinc)
    theme.define_singleton_method(:destroy) { false }

    assert_equal :not_destroyed, Themes::Operation::Destroy.new.call(model: theme).failure[:code]
  end
end
