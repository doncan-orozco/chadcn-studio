require "test_helper"

class ApplicationQueryTest < ActiveSupport::TestCase
  class Evens < ApplicationQuery
    base_scope { (1..10).to_a }

    pipeline :only_even, :limit_to

    private

    def only_even(current_scope) = current_scope.select(&:even?)

    def limit_to(current_scope) = filters[:limit] ? current_scope.first(filters[:limit].to_i) : current_scope
  end

  class Bare < ApplicationQuery; end

  test "runs the pipeline over the base scope" do
    assert_equal [ 2, 4, 6, 8, 10 ], Evens.call
  end

  test "filters accept string keys" do
    assert_equal [ 2, 4 ], Evens.call({ "limit" => "2" })
  end

  test "a caller scope replaces the base scope" do
    assert_equal [ 4 ], Evens.call({}, scope: [ 3, 4, 5 ])
  end

  test "a query without a base scope is an error" do
    assert_raises(NotImplementedError) { Bare.call }
  end
end
