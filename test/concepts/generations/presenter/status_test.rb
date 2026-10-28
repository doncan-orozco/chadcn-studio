require "test_helper"

class Generations::Presenter::StatusTest < ActiveSupport::TestCase
  test "pending, done and failed" do
    assert_equal :pending, Generations::Presenter::Status.new(generations(:pending)).state
    assert_equal :done, Generations::Presenter::Status.new(generations(:completed)).state
    failed = Generations::Presenter::Status.new(generations(:failed))

    assert_equal :failed, failed.state
    assert_match(/Try again|differently|another prompt/, failed.message)
  end

  test "done shows the model's rationale" do
    generation = generations(:completed)
    generation.inputs = { "rationale" => "Warm and calm." }

    assert_equal "Warm and calm.", Generations::Presenter::Status.new(generation).message
  end

  test "the rationale is capped at 280 characters" do
    generation = generations(:completed)
    generation.inputs = { "rationale" => "a" * 400 }

    assert_equal "a" * 280, Generations::Presenter::Status.new(generation).rationale
  end

  test "busy and throttled failures have their own messages" do
    assert_match(/already being generated/, Generations::Presenter::Status.new(Generation.new, failure: :busy).message)
    assert_match(/Too many generations/, Generations::Presenter::Status.new(Generation.new, failure: :throttled).message)
  end

  test "a prompt the form rejected is a failure with its own message" do
    status = Generations::Presenter::Status.new(Generation.new, failure: :prompt)

    assert_equal :failed, status.state
    assert_match(/1 to 2000/, status.message)
    assert_predicate status, :failed?
  end

  test "a stored failure is failed and a pending generation is not" do
    assert_predicate Generations::Presenter::Status.new(generations(:failed)), :failed?
    assert_not Generations::Presenter::Status.new(generations(:pending)).failed?
  end

  test "an abandoned pending generation reads as failed with the unavailable message" do
    travel Generations::Service::Deadline::ABANDONED_AFTER + 1.minute do
      status = Generations::Presenter::Status.new(generations(:pending))

      assert_predicate status, :failed?
      assert_equal :failed, status.state
      assert_match(/unavailable/, status.message)
    end
  end
end
