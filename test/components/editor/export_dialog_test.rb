require "test_helper"

class Components::Editor::ExportDialogTest < ActiveSupport::TestCase
  Sharing = Struct.new(:published, :publication_path, :dialog_title, keyword_init: true) do
    def published? = published
  end

  test "a draft's dialog carries a Publish form that posts to the publication" do
    fragment = Nokogiri::HTML5.fragment(render_dialog(published: false))

    assert_equal "/themes/1/publication", fragment.at_css("form")["action"]
    assert_equal "post", fragment.at_css("form")["method"]
    assert_equal "Publish", fragment.at_css("[data-testid=export-publish]").text
    assert_nil fragment.at_css("[data-testid=download-css]")
  end

  private

  def render_dialog(published:)
    dialog = Components::Editor::ExportDialog.new(presenter: Sharing.new(published:, publication_path: "/themes/1/publication", dialog_title: "Export Zinc"))
    controller = ApplicationController.new.tap { |instance| instance.request = ActionDispatch::TestRequest.create }
    controller.view_context.render(dialog)
  end
end
