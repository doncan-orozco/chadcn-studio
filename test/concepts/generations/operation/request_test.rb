require "test_helper"

class Generations::Operation::RequestTest < ActiveSupport::TestCase
  test "creates a pending generation and enqueues the job with its id" do
    enqueued = []
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:zinc), prompt: "  warm sunset ")
    generation = result.value![:model]

    assert_equal "warm sunset", generation.prompt
    assert_predicate generation, :pending?
    assert_equal [ generation.id ], enqueued
  end

  test "a blank prompt fails with :invalid and enqueues nothing" do
    enqueued = []
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:zinc), prompt: " ")

    assert_equal :invalid, result.failure[:code]
    assert_empty enqueued
  end
end
