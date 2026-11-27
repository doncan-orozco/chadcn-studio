require "test_helper"

class Components::Editor::GenerationPanelTest < ActiveSupport::TestCase
  test "configured: the prompt and Generate are enabled and the status is empty" do
    html = render_panel(configured: true)

    assert_no_match(/<input[^>]* disabled[ >=]/, html)
    assert_no_match(/<button[^>]* disabled[ >=]/, html)
    assert_no_match(/ANTHROPIC_API_KEY/, html)
    assert_includes html, "turbo-cable-stream-source"
  end

  test "not configured: no form, no prompt, no Generate; the line that says why" do
    html = render_panel(configured: false)

    assert_no_match(/<form/, html)
    assert_no_match(/turbo-cable-stream-source/, html)
    assert_no_match(/<input/, html)
    assert_no_match(/data-testid="generate"/, html)
    assert_includes html, "set ANTHROPIC_API_KEY and restart the studio"
    assert_includes html, 'id="generation_status"'
  end

  private

  def render_panel(configured:)
    panel = Generations::Presenter::Panel.new(themes(:blue), configured: configured)
    ApplicationController.render(Components::Editor::GenerationPanel.new(panel: panel), layout: false)
  end
end
