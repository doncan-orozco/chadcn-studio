require "test_helper"

class Themes::GenerationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "POST answers a pending status stream and enqueues the job" do
    assert_enqueued_with(job: GenerateThemeJob) do
      post theme_generations_path(themes(:zinc)), params: { generation: { prompt: "warm sunset" } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal Mime[:turbo_stream], response.media_type
    assert_includes response.body, 'target="generation_status"'
    assert_includes response.body, "Generating a theme"
    assert_equal "warm sunset", themes(:zinc).generations.order(:id).last.prompt
  end

  test "a blank prompt answers 422 with a readable message and enqueues nothing" do
    assert_no_enqueued_jobs do
      post theme_generations_path(themes(:zinc)), params: { generation: { prompt: " " } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "1 to 2000"
  end

  test "an unknown theme is 404" do
    post theme_generations_path(0), params: { generation: { prompt: "x" } }, as: :turbo_stream

    assert_response :not_found
  end

  test "the editor shows the prompt form and subscribes to the theme's stream" do
    get edit_theme_path(themes(:zinc))

    assert_select "[data-testid=generation-form]"
    assert_select "turbo-cable-stream-source"
    assert_select "#generation_status"
  end
end
