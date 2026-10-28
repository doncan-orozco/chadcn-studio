require "application_system_test_case"

# The job is performed by the test once the pending status shows, and the stream reaches the browser through an in-process cable.
class GenerationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    @adapter = ActionCable.server.config.cable
    ActionCable.server.config.cable = { "adapter" => "async" }
    ActionCable.server.restart
  end

  teardown do
    GenerateThemeJob.client = nil
    ActionCable.server.config.cable = @adapter
    ActionCable.server.restart
  end

  test "a prompt shows a status and the generated palette lands in the editor" do
    GenerateThemeJob.client = FakeGenerationClient.new
    visit edit_theme_path(themes(:slate))

    fill_in "Describe a theme", with: "calm blue"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "Generating a theme"
    perform_enqueued_jobs

    assert_selector :testid, "generation-status", text: "A confident blue with soft corners."
    assert_selector :testid, "preview-root", visible: :all, style: /--primary: oklch\(0\.55 0\.2 250\)/
    assert_equal "oklch(0.55 0.2 250)", themes(:slate).reload.inputs["primary"]
  end

  test "a refusal is explained and nothing changes" do
    GenerateThemeJob.client = FakeGenerationClient.refusing
    visit edit_theme_path(themes(:slate))

    fill_in "Describe a theme", with: "something"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "Generating a theme"
    perform_enqueued_jobs

    assert_selector :testid, "generation-status", text: "declined"
  end
end
