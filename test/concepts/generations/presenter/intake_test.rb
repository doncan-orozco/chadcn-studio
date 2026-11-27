require "test_helper"

class Generations::Presenter::IntakeTest < ActiveSupport::TestCase
  test "answers what the editor's panel answers, without a theme to listen to" do
    intake = Generations::Presenter::Intake.for(prompt: "calm blue", configured: true)

    assert_predicate intake, :configured?
    assert_equal "/generations", intake.create_path
    assert_nil intake.stream_source
    assert_equal "generation[prompt]", intake.prompt_param
    assert_equal "calm blue", intake.prompt
    assert_nil intake.status
    assert_equal "Or describe it", intake.title
    assert_includes intake.description, "Claude picks the colors"
  end

  test "a studio that cannot generate says so" do
    intake = Generations::Presenter::Intake.for(configured: false)

    refute_predicate intake, :configured?
    assert_nil intake.title
    assert_nil intake.description
    assert_predicate intake.status, :failed?
    assert_includes intake.status.message, "ANTHROPIC_API_KEY"
  end
end
