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

  test "a prompt the form rejected is a failure with its own message" do
    status = Generations::Presenter::Status.new(Generation.new, failure: :prompt)

    assert_equal :failed, status.state
    assert_match(/1 to 2000/, status.message)
  end
end
