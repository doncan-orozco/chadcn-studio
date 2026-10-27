require "test_helper"

class GenerationTest < ActiveSupport::TestCase
  test "fixtures cover one generation per state" do
    assert_predicate generations(:pending), :pending?
    assert_predicate generations(:completed), :completed?
    assert_predicate generations(:failed), :failed?
  end

  test "states are exclusive" do
    assert_not_predicate generations(:completed), :pending?
    assert_not_predicate generations(:completed), :failed?
    assert_not_predicate generations(:failed), :pending?
    assert_not_predicate generations(:failed), :completed?
  end

  test "failed generation keeps its error code" do
    assert_equal "refusal", generations(:failed).error_code
  end

  test "prompt is required and capped" do
    generation = Generation.new(theme: themes(:zinc), prompt: "")

    assert_not generation.valid?
    assert_includes generation.errors[:prompt], "can't be blank"

    generation.prompt = "x" * 2001

    assert_not generation.valid?
  end

  test "a prompt of exactly 2000 characters is valid" do
    assert_predicate Generation.new(theme: themes(:zinc), prompt: "x" * 2000), :valid?
  end

  test "database rejects a generation that both completed and failed" do
    assert_raises(ActiveRecord::StatementInvalid) do
      generations(:completed).update_columns(failed_at: Time.current, error_code: "refusal")
    end
  end

  test "database rejects a failure without an error code" do
    assert_raises(ActiveRecord::StatementInvalid) do
      generations(:pending).update_columns(failed_at: Time.current)
    end
  end

  test "belongs to a theme" do
    assert_equal themes(:slate), generations(:completed).theme
  end
end
