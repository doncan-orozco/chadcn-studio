require "test_helper"

class Generations::Operation::FailTest < ActiveSupport::TestCase
  test "marks a pending generation failed with the code" do
    generation = generations(:pending)
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable)

    assert_predicate generation.reload, :failed?
    assert_equal "unavailable", generation.error_code
  end

  test "rejects a code outside the known failure codes" do
    generation = generations(:pending)

    assert_raises(ArgumentError) { Generations::Operation::Fail.new.call(model: generation, code: :prompt) }
    assert_predicate generation.reload, :pending?
  end

  test "does not touch a generation that already finished" do
    generation = generations(:completed)
    Generations::Operation::Fail.new.call(model: generation, code: :unavailable)

    assert_predicate generation.reload, :completed?
    assert_nil generation.error_code
  end
end
