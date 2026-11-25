require "test_helper"

class Components::Editor::GenerationPanelTest < ActiveSupport::TestCase
  test "configured: the prompt and Generate are enabled and the status is empty" do
    html = render_panel(configured: true)

    assert_no_match(/<input[^>]* disabled[ >=]/, html)
    assert_no_match(/<button[^>]* disabled[ >=]/, html)
    assert_no_match(/not set up/, html)
  end

  test "not configured: the prompt and Generate are disabled and the status says why" do
    html = render_panel(configured: false)

    assert_match(/<input[^>]* disabled[ >=]/, html)
    assert_match(/<button[^>]* disabled[ >=]/, html)
    assert_includes html, "Generation is not set up in this studio."
    assert_no_match(/aria-invalid="true"/, html)
  end

  private

  def render_panel(configured:)
    panel = Generations::Presenter::Panel.new(themes(:blue), configured: configured)
    ApplicationController.render(Components::Editor::GenerationPanel.new(panel: panel), layout: false)
  end
end
