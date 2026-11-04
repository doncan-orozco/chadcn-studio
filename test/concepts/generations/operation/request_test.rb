require "test_helper"

class Generations::Operation::RequestTest < ActiveSupport::TestCase
  test "creates a pending generation and enqueues the job with its id" do
    enqueued = []
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:slate), prompt: "  warm sunset ")
    generation = result.value![:model]

    assert_equal "warm sunset", generation.prompt
    assert_predicate generation, :pending?
    assert_equal [ generation.id ], enqueued
  end

  test "a theme whose latest generation is pending fails with :busy and enqueues nothing" do
    enqueued = []
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:zinc), prompt: "again")

    assert_equal :busy, result.failure[:code]
    assert_empty enqueued
    assert_equal 1, themes(:zinc).generations.count
  end

  test "a blank prompt fails with :invalid and enqueues nothing" do
    enqueued = []
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:slate), prompt: " ")

    assert_equal :invalid, result.failure[:code]
    assert_empty enqueued
  end

  test "a pending generation older than the deadline no longer blocks" do
    travel Generations::Service::Deadline::ABANDONED_AFTER + 1.minute do
      enqueued = []
      result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:zinc), prompt: "again")

      assert_predicate result, :success?
      assert_equal [ result.value![:model].id ], enqueued
    end
  end

  test "an enqueue that raises marks the generation failed and re-raises" do
    boom = ->(_id) { raise IOError, "queue down" }

    assert_raises(IOError) { Generations::Operation::Request.new(enqueue: boom).call(theme: themes(:slate), prompt: "warm") }
    generation = themes(:slate).generations.order(:id).last

    assert_equal "warm", generation.prompt
    assert_equal "unavailable", generation.error_code
  end

  test "the site-wide count in the last hour at the cap fails with :capped, saves nothing and enqueues nothing" do
    enqueued = []
    cap = Generation.where(created_at: 1.hour.ago..).count
    result = Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:slate), prompt: "one more", hourly_cap: cap)

    assert_equal :capped, result.failure[:code]
    assert_empty enqueued
    assert_no_difference -> { Generation.count } do
      Generations::Operation::Request.new(enqueue: ->(id) { enqueued << id }).call(theme: themes(:slate), prompt: "again", hourly_cap: cap)
    end
  end

  test "generations older than an hour do not count toward the cap" do
    Generation.update_all(created_at: 2.hours.ago)
    result = Generations::Operation::Request.new(enqueue: ->(_id) { }).call(theme: themes(:slate), prompt: "fresh", hourly_cap: 1)

    assert_predicate result, :success?
  end

  test "a cap of nil or 0 disables the check" do
    { nil => themes(:slate), 0 => themes(:blue) }.each do |cap, theme|
      result = Generations::Operation::Request.new(enqueue: ->(_id) { }).call(theme: theme, prompt: "free", hourly_cap: cap)

      assert_predicate result, :success?
    end
  end
end
