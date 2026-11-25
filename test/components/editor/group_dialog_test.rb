require "test_helper"

class Components::Editor::GroupDialogTest < ActiveSupport::TestCase
  Group = Struct.new(:key, :label, :description, :summary, :panel_id, :summary_id, keyword_init: true)

  test "the sublabel switches to the accent foreground where the entry is open, active or hovered" do
    html = render_dialog
    sublabel = html[/<span id="summary-dark"[^>]*>/]

    assert_includes sublabel, "text-muted-foreground"
    assert_includes sublabel, "in-data-[state=open]:text-sidebar-accent-foreground"
    assert_includes sublabel, "in-data-[active=true]:text-sidebar-accent-foreground"
    assert_includes sublabel, "in-hover:text-sidebar-accent-foreground"
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
