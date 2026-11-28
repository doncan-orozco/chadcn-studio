require "test_helper"

class Components::Editor::ExportDialogTest < ActiveSupport::TestCase
  def render_dialog(theme, **options)
    sharing = Exports::Presenter::Sharing.new(theme, base_url: "https://studio.test")
    Nokogiri::HTML5.fragment(ApplicationController.render(Components::Editor::ExportDialog.new(presenter: sharing, **options), layout: false))
  end

  def dialog_id(html) = html.at_css("[data-chadcn--dialog-id-value]")["data-chadcn--dialog-id-value"]

  test "the host and the dialog are named after the theme, so several can share a page" do
    blue = render_dialog(themes(:blue))
    slate = render_dialog(themes(:slate))

    assert blue.at_css("##{Components::Editor::ExportDialog.host_id(themes(:blue).id)}")
    assert slate.at_css("##{Components::Editor::ExportDialog.host_id(themes(:slate).id)}")
    assert_not_equal dialog_id(blue), dialog_id(slate)
  end

  test "the editor's trigger is a plain Export button" do
    trigger = render_dialog(themes(:blue)).at_css("[data-testid=export]")

    assert_equal "Export", trigger.text.strip
    assert_nil trigger["aria-label"]
  end

  test "the editor's trigger is the default look that goes outline once the editor is dirty; a row's stays outline" do
    editor = render_dialog(themes(:blue)).at_css("[data-testid=export]")
    row = render_dialog(themes(:blue), compact: true).at_css("[data-testid=export]")

    assert_equal "export", editor["data-editor--preview-target"]
    assert_includes editor["class"], "data-[dirty]:bg-background"
    assert_includes editor["class"], "bg-primary"
    assert_nil row["data-editor--preview-target"]
    assert_not_includes row["class"], "bg-primary"
  end

  test "a row's trigger is small and named after its theme, starting with the visible text" do
    trigger = render_dialog(themes(:blue), compact: true).at_css("[data-testid=export]")

    assert_equal "Export", trigger.text.strip
    assert_equal "Export Blue", trigger["aria-label"]
  end
end
