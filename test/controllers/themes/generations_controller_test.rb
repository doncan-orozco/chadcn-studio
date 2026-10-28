require "test_helper"

class Themes::GenerationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "POST answers a pending status stream and enqueues the job" do
    assert_enqueued_with(job: GenerateThemeJob) do
      post theme_generations_path(themes(:slate)), params: { generation: { prompt: "warm sunset" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal Mime[:turbo_stream], response.media_type
    assert_includes response.body, 'target="generation_status"'
    assert_includes response.body, "Generating a theme"
    assert_equal "warm sunset", themes(:slate).generations.order(:id).last.prompt
  end

  test "a blank prompt answers 422 with a readable message and enqueues nothing" do
    assert_no_enqueued_jobs do
      post theme_generations_path(themes(:slate)), params: { generation: { prompt: " " } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "1 to 2000"
  end

  test "an unknown theme is 404" do
    post theme_generations_path(0), params: { generation: { prompt: "x" } }, as: :turbo_stream

    assert_response :not_found
  end

  test "a theme that is already generating answers 422 with the busy message and enqueues nothing" do
    assert_no_enqueued_jobs do
      post theme_generations_path(themes(:zinc)), params: { generation: { prompt: "another" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "already being generated"
  end

  test "more than five generations a minute from one address answer 429" do
    memory = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.define_singleton_method(:increment) { |key, amount = 1, **options| memory.increment(key, amount, **options) }
    5.times { post theme_generations_path(themes(:slate)), params: { generation: { prompt: "x" } }, as: :turbo_stream }
    assert_no_enqueued_jobs only: GenerateThemeJob do
      post theme_generations_path(themes(:blue)), params: { generation: { prompt: "y" } }, as: :turbo_stream
    end

    assert_response :too_many_requests
    assert_includes response.body, "Too many generations"
  ensure
    Rails.cache.singleton_class.remove_method(:increment)
  end

  test "the editor shows the prompt form and subscribes to the theme's stream" do
    get edit_theme_path(themes(:zinc))

    assert_select "[data-testid=generation-form]"
    assert_select "turbo-cable-stream-source"
    assert_select "#generation_status"
  end
end
