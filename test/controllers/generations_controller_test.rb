require "test_helper"

class GenerationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { GenerateThemeJob.client = FakeGenerationClient.new }
  teardown { GenerateThemeJob.client = nil }

  test "POST creates a theme, enqueues the job and opens the editor" do
    assert_enqueued_with(job: GenerateThemeJob) do
      assert_difference -> { Theme.count } => 1 do
        post generations_path, params: { generation: { prompt: "warm sunset" } }
      end
    end

    theme = Theme.find_by!(name: "warm sunset")

    assert_redirected_to edit_theme_path(theme)
    assert_equal "warm sunset", theme.generations.first.prompt
  end

  test "the editor opens with a toast naming the new theme, and its card says New until the editor is opened after the list" do
    post generations_path, params: { generation: { prompt: "warm sunset" } }
    theme = Theme.find_by!(name: "warm sunset")

    follow_redirect!

    assert_equal "Created warm sunset from your description", flash[:notice]

    get edit_theme_path(theme)
    get themes_path

    assert_select "[data-testid=theme-card]:has(a[href=?]) [data-testid=new-badge]", edit_theme_path(theme), text: "New"

    get edit_theme_path(theme), headers: { "X-Sec-Purpose" => "prefetch" }
    get themes_path

    assert_select "[data-testid=new-badge]", count: 1

    get edit_theme_path(theme)
    get themes_path

    assert_select "[data-testid=new-badge]", count: 0
  end

  test "a blank prompt re-renders New theme with a readable message and creates nothing" do
    assert_no_enqueued_jobs do
      assert_no_difference -> { Theme.count } do
        post generations_path, params: { generation: { prompt: " " } }
      end
    end

    assert_response :unprocessable_entity
    assert_select "[data-testid=generation-status]", text: /1 to 2000/
    assert_select "[data-testid=new-theme-form]"
  end

  test "a prompt that cannot start keeps what was typed" do
    original = Rails.configuration.x.generations.hourly_cap
    Rails.configuration.x.generations.hourly_cap = 1
    post generations_path, params: { generation: { prompt: "calm blue" } }

    assert_response :unprocessable_entity
    assert_select "[data-testid=generation-status]", text: /hourly generation limit/
    assert_select "input#generation-prompt[value=?]", "calm blue"
  ensure
    Rails.configuration.x.generations.hourly_cap = original
  end

  test "the sixth request in a minute is throttled and creates nothing" do
    memory = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.define_singleton_method(:increment) { |key, amount = 1, **options| memory.increment(key, amount, **options) }
    5.times { post generations_path, params: { generation: { prompt: "x" } } }

    assert_no_difference -> { Theme.count } do
      post generations_path, params: { generation: { prompt: "y" } }
    end
    assert_response :too_many_requests
    assert_select "[data-testid=generation-status]", text: /Too many generations/
  ensure
    Rails.cache.singleton_class.remove_method(:increment)
  end

  test "an unconfigured studio refuses a crafted POST and creates nothing" do
    GenerateThemeJob.client = nil
    key = ENV.delete("ANTHROPIC_API_KEY")

    assert_no_difference -> { Theme.count } do
      post generations_path, params: { generation: { prompt: "calm blue" } }
    end
    assert_response :unprocessable_entity
    assert_select "[data-testid=generation-status]", text: /ANTHROPIC_API_KEY/
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end
end
