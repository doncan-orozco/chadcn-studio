require "test_helper"

class Generations::Presenter::PanelTest < ActiveSupport::TestCase
  test "for loads the latest generation of the theme as its status" do
    theme = generations(:pending).theme
    newest = theme.generations.create!(prompt: "newest")

    assert_equal newest, Generations::Presenter::Panel.for(theme, configured: true).status.__getobj__
  end

  test "a theme with no generation has no status" do
    assert_nil Generations::Presenter::Panel.new(themes(:blue), configured: true).status
  end

  test "exposes the prompt field settings" do
    panel = Generations::Presenter::Panel.new(themes(:blue), configured: true)

    assert_equal "generation[prompt]", panel.prompt_param
    assert_equal 2000, panel.prompt_limit
    assert_predicate panel.prompt_placeholder, :present?
  end

  test "a studio not configured says so in its status" do
    panel = Generations::Presenter::Panel.new(themes(:blue), configured: false)

    assert_equal :failed, panel.status.state
    assert_match(/not set up/, panel.status.message)
  end

  test "a studio without a key or an injected client is not configured" do
    key = ENV.delete("ANTHROPIC_API_KEY")

    refute_predicate Generations::Presenter::Panel.new(themes(:blue)), :configured?
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end

  test "an injected client makes the studio configured" do
    GenerateThemeJob.client = FakeGenerationClient.new

    assert_predicate Generations::Presenter::Panel.new(themes(:blue)), :configured?
  ensure
    GenerateThemeJob.client = nil
  end
end
