require "test_helper"

class Generations::Operation::BeginTest < ActiveSupport::TestCase
  test "creates a placeholder theme named from the prompt and a pending generation for it" do
    enqueued = []
    operation = Generations::Operation::Begin.new(request: Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }))

    assert_difference -> { Theme.count } => 1, -> { Generation.count } => 1 do
      result = operation.call(prompt: "  warm sunset ")
      payload = result.value!

      assert_equal "warm sunset", payload[:model].name
      assert_equal payload[:model], payload[:generation].theme
      assert_predicate payload[:generation], :pending?
      assert_equal [ payload[:generation].id ], enqueued
    end
  end

  test "a long prompt is shortened to a name" do
    result = Generations::Operation::Begin.new(request: Generations::Operation::Request.new(enqueue: ->(_id) { })).call(prompt: "calm " * 60)

    assert_operator result.value![:model].name.length, :<=, 40
  end

  test "a blank prompt fails with :invalid and leaves no theme" do
    assert_no_difference -> { Theme.count } do
      result = Generations::Operation::Begin.new.call(prompt: " ")

      assert_equal :invalid, result.failure[:code]
    end
  end

  test "a site at its cap fails with :capped and removes the placeholder" do
    enqueued = []
    operation = Generations::Operation::Begin.new(request: Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }))

    assert_no_difference -> { Theme.count } do
      result = operation.call(prompt: "calm blue", hourly_cap: 1)

      assert_equal :capped, result.failure[:code]
    end
    assert_empty enqueued
  end
end
