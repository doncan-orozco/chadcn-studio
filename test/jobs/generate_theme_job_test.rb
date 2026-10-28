require "test_helper"

class GenerateThemeJobTest < ActiveJob::TestCase
  teardown { GenerateThemeJob.client = nil }

  test "runs the operation with the injected client" do
    GenerateThemeJob.client = FakeGenerationClient.new
    GenerateThemeJob.perform_now(generations(:pending).id)

    assert_predicate generations(:pending).reload, :completed?
  end

  test "is idempotent" do
    client = GenerateThemeJob.client = FakeGenerationClient.new
    2.times { GenerateThemeJob.perform_now(generations(:pending).id) }

    assert_equal 1, client.prompts.size
  end

  test "a vanished generation is discarded" do
    GenerateThemeJob.client = FakeGenerationClient.new

    assert_nothing_raised { GenerateThemeJob.perform_now(0) }
  end

  test "retries a transient error and fails the generation as :unavailable when the retries run out" do
    GenerateThemeJob.client = FakeGenerationClient.new(error: Generations::Transient.new("rate"))
    generation = generations(:pending)

    perform_enqueued_jobs(only: GenerateThemeJob) do
      assert_nothing_raised { GenerateThemeJob.perform_later(generation.id) }
    end

    assert_equal "unavailable", generation.reload.error_code
  end

  test "an unexpected error fails the generation as :unavailable, is logged and re-raised" do
    GenerateThemeJob.client = FakeGenerationClient.new(error: RuntimeError.new("boom"))
    generation = generations(:pending)
    io = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(io)

    assert_raises(RuntimeError) { GenerateThemeJob.perform_now(generation.id) }

    assert_equal "unavailable", generation.reload.error_code
    assert_includes io.string, "generation #{generation.id}: RuntimeError: boom"
  ensure
    Rails.logger = original
  end

  test "uses the generation queue" do
    assert_equal "generation", GenerateThemeJob.new.queue_name
  end
end
