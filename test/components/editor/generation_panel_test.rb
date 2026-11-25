require "test_helper"

class Components::Editor::GenerationPanelTest < ActiveSupport::TestCase
  test "with a client the prompt and Generate are enabled and the status is empty" do
    GenerateThemeJob.client = FakeGenerationClient.new
    html = render_panel

    assert_no_match(/<input[^>]* disabled[ >=]/, html)
    assert_no_match(/<button[^>]* disabled[ >=]/, html)
    assert_no_match(/not set up/, html)
  ensure
    GenerateThemeJob.client = nil
  end

  test "without a client the prompt and Generate are disabled and the status says why" do
    html = without_api_key { render_panel }

    assert_match(/<input[^>]* disabled[ >=]/, html)
    assert_match(/<button[^>]* disabled[ >=]/, html)
    assert_includes html, "Generation is not set up in this studio."
    assert_no_match(/aria-invalid="true"/, html)
  end

  private

  def render_panel
    ApplicationController.render(Components::Editor::GenerationPanel.new(panel: Generations::Presenter::Panel.new(themes(:blue))), layout: false)
  end

  def without_api_key
    key = ENV.delete("ANTHROPIC_API_KEY")
    yield
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end
end
