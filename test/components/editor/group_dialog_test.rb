require "test_helper"

class Components::Editor::GroupDialogTest < ActiveSupport::TestCase
  Group = Struct.new(:key, :label, :description, :summary, :summary_style, :panel_id, :summary_id, keyword_init: true)

  test "the entry shows the group's label and summary in its trigger" do
    html = render_dialog

    assert_includes html, "Dark mode"
    assert_includes html, ">System</span>"
    assert_includes html, 'id="summary-dark"'
  end

  test "a summary with a color puts a decorative chip before the text" do
    html = render_dialog(summary: "#18181b", summary_style: "background-color: oklch(0.21 0.006 285.885)")

    assert_includes html, 'aria-hidden="true"'
    assert_includes html, "background-color: oklch(0.21 0.006 285.885)"
    assert_includes html, "#18181b"
  end

  private

  def render_dialog(**overrides)
    dialog = Components::Editor::GroupDialog.new(group: group(**overrides))
    host = Class.new(Components::Base) { define_method(:view_template) { render(Chadcn::Sidebar::Provider.new { render dialog }) } }
    host.new.call
  end

  def group(**overrides)
    Group.new(key: "dark", label: "Dark mode", description: "Light, dark or system.", summary: "System", summary_style: nil, panel_id: "group-dark", summary_id: "summary-dark", **overrides)
  end
end
