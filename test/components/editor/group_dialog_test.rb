require "test_helper"

class Components::Editor::GroupDialogTest < ActiveSupport::TestCase
  Group = Struct.new(:key, :label, :description, :summary, :panel_id, :summary_id, keyword_init: true)

  test "the entry shows the group's label and summary in its trigger" do
    html = render_dialog

    assert_includes html, "Dark mode"
    assert_includes html, ">System</span>"
    assert_includes html, 'id="summary-dark"'
  end

  private

  def render_dialog
    dialog = Components::Editor::GroupDialog.new(group: group)
    host = Class.new(Components::Base) { define_method(:view_template) { render(Chadcn::Sidebar::Provider.new { render dialog }) } }
    host.new.call
  end

  def group
    Group.new(key: "dark", label: "Dark mode", description: "Light, dark or system.", summary: "System", panel_id: "group-dark", summary_id: "summary-dark")
  end
end
