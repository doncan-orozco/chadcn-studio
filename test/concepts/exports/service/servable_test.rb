require "test_helper"

class Exports::Service::ServableTest < ActiveSupport::TestCase
  test "a valid stored palette is servable" do
    assert Exports::Service::Servable.call(themes(:slate))
  end

  test "a stored palette missing a variable is not servable" do
    theme = themes(:slate)
    theme.light = theme.light.except("primary")

    assert_not Exports::Service::Servable.call(theme)
  end
end
