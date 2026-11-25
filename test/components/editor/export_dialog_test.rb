require "test_helper"

class Components::Editor::ExportDialogTest < ActiveSupport::TestCase
  Sharing = Struct.new(:published, :publication_path, :dialog_title, keyword_init: true) do
    def published? = published
    def unpublish? = published
    def publication_label = published ? "Unpublish" : "Publish"
  end

  test "a draft's dialog carries a Publish form that posts to the publication" do
    fragment = Nokogiri::HTML5.fragment(render_dialog(published: false))

    assert_equal "/themes/1/publication", fragment.at_css("form")["action"]
    assert_equal "post", fragment.at_css("form")["method"]
    assert_equal "Publish", fragment.at_css("[data-testid=export-publish]").text
    assert_nil fragment.at_css("[data-testid=download-css]")
  end

  test "a published theme's dialog shows the downloads and the import command, no Publish form" do
    sharing = Exports::Presenter::Sharing.new(Themes::Presenter::Editor.new(themes(:slate)), base_url: "http://example.test")
    fragment = Nokogiri::HTML5.fragment(render_component(Components::Editor::ExportDialog.new(presenter: sharing)))

    assert fragment.at_css("[data-testid=download-css]")
    assert fragment.at_css("[data-testid=download-json]")
    assert_match(%r{\Abin/rails theme:import\[http://example\.test/t/slate\.css\]\z}, fragment.at_css("[data-testid=import-command]")["value"])
    assert_nil fragment.at_css("[data-testid=export-publish]")
  end

  private

  def render_dialog(published:)
    render_component(Components::Editor::ExportDialog.new(presenter: Sharing.new(published:, publication_path: "/themes/1/publication", dialog_title: "Export Zinc")))
  end

  def render_component(component)
    controller = ApplicationController.new.tap { |instance| instance.request = ActionDispatch::TestRequest.create }
    controller.view_context.render(component)
  end
end
