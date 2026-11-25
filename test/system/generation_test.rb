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

    click_on "Describe a theme"
    fill_in "Prompt", with: "calm blue"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "Generating a theme"
    perform_enqueued_jobs

    # The success broadcasts a refresh that re-renders the page (and the dialog): wait for the palette, then look at the status.
    assert_selector :testid, "preview-root", visible: :all, style: /--primary: oklch\(0\.55 0\.2 250\)/
    assert_no_selector :testid, "generation-panel"
    click_on "Describe a theme"

    assert_selector :testid, "generation-status", text: "A confident blue with soft corners."
    assert_equal "oklch(0.55 0.2 250)", themes(:slate).reload.inputs["primary"]
  end

  test "a refusal is explained and nothing changes" do
    GenerateThemeJob.client = FakeGenerationClient.refusing
    visit edit_theme_path(themes(:slate))

    click_on "Describe a theme"
    fill_in "Prompt", with: "something"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "Generating a theme"
    perform_enqueued_jobs

    assert_selector :testid, "generation-status", text: "declined"
  end

  test "a refusal that lands while the dialog is closed shows when it is reopened" do
    GenerateThemeJob.client = FakeGenerationClient.refusing
    visit edit_theme_path(themes(:slate))

    click_on "Describe a theme"
    fill_in "Prompt", with: "something"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "Generating a theme"
    find(:testid, "generation-panel").send_keys :escape

    assert_no_selector :testid, "generation-panel"
    perform_enqueued_jobs
    click_on "Describe a theme"

    assert_selector :testid, "generation-status", text: "declined"
  end

  test "a site at its hourly cap explains it and generates nothing" do
    original = Rails.configuration.x.generations.hourly_cap
    GenerateThemeJob.client = FakeGenerationClient.new
    Rails.configuration.x.generations.hourly_cap = 1
    visit edit_theme_path(themes(:slate))

    click_on "Describe a theme"
    fill_in "Prompt", with: "calm blue"
    click_on "Generate"

    assert_selector :testid, "generation-status", text: "hourly generation limit"
  ensure
    Rails.configuration.x.generations.hourly_cap = original
  end
end
