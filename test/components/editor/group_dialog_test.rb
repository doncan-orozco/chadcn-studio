require "test_helper"

class Components::Editor::GroupDialogTest < ActiveSupport::TestCase
  Group = Struct.new(:key, :label, :description, :summary, :panel_id, :summary_id, :trigger_id, keyword_init: true)

  test "the entry shows the group's label and summary in its trigger" do
    html = render_dialog

    assert_includes html, "Dark mode"
    assert_includes html, ">System</span>"
    assert_includes html, 'id="summary-dark"'
  end

  test "read-only groups link to Advanced; brand, radius and advanced do not" do
    html = ->(key) { render_dialog(Themes::Presenter::Group.new(themes(:zinc), key: key)) }

    assert_includes html.("surfaces"), "To set one exactly, use Advanced"
    assert_includes html.("surfaces"), 'data-editor--panel-link-trigger-id-value="group-advanced-trigger"'
    %w[brand radius advanced].each { |key| refute_includes html.(key), "editor--panel-link", key }
  end

  test "the inline brand group tells what Save does after the live changes" do
    html = render_dialog(Themes::Presenter::Group.new(themes(:zinc), key: "brand"))

    assert_includes html, "Changes show live; Save keeps them."
  end

  test "the brand variables summary says what it holds, in readable text" do
    html = render_dialog(Themes::Presenter::Group.new(themes(:zinc), key: "brand"))

    assert_match(%r{<summary class="[^"]*text-foreground/70[^"]*">Brand variables \(light and dark values\)</summary>}, html)
    assert_not_includes html, "All brand variables"
  end

  test "the Advanced entry carries the trigger id the links name" do
    assert_includes render_dialog(Themes::Presenter::Group.new(themes(:zinc), key: "advanced")), 'id="group-advanced-trigger"'
  end

  test "the See all values link names the group it opens" do
    html = render_dialog(Themes::Presenter::Group.new(themes(:zinc), key: "surfaces"))

    assert_match(/<a [^>]*aria-label="See all values for Backgrounds, cards and text"[^>]*>See all values<\/a>/, html)
  end

  test "the popover's content may shrink its children, so nothing runs past its box" do
    assert_includes render_dialog, "[&>*]:min-w-0"
  end

  private

  def render_dialog(subject = group)
    dialog = Components::Editor::GroupDialog.new(group: subject)
    host = Class.new(Components::Base) { define_method(:view_template) { render(Chadcn::Sidebar::Provider.new { render dialog }) } }
    host.new.call
  end

  def group
    Group.new(key: "dark", label: "Dark mode", description: "Light, dark or system.", summary: "System", panel_id: "group-dark", summary_id: "summary-dark", trigger_id: "group-dark-trigger")
  end
end
