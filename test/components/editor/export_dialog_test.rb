require "test_helper"

class Components::Editor::ExportDialogTest < ActiveSupport::TestCase
  test "a draft's dialog carries a Publish form that posts to the publication" do
    theme = themes(:zinc)
    fragment = Nokogiri::HTML5.fragment(render_dialog(theme))
    form = fragment.at_css("form")

    assert_equal "/themes/#{theme.id}/publication", form["action"]
    assert_equal "post", form["method"]
    assert_nil form.at_css("input[name=_method]")
    assert form.at_css("input[name=authenticity_token]")
    assert_equal "Publish", fragment.at_css("[data-testid=export-publish]").text
    assert fragment.at_css("[data-testid=export-draft]")
    assert_nil fragment.at_css("[data-testid=download-css]")
  end

  test "a published theme's dialog shows the downloads and the import command, no Publish form" do
    fragment = Nokogiri::HTML5.fragment(render_dialog(themes(:slate)))

    assert fragment.at_css("[data-testid=download-css]")
    assert fragment.at_css("[data-testid=download-json]")
    assert_match(%r{\Abin/rails theme:import\[http://example\.test/t/slate\.css\]\z}, fragment.at_css("[data-testid=import-command]")["value"])
    assert_nil fragment.at_css("[data-testid=export-publish]")
  end

  private

  def render_dialog(theme)
    sharing = Exports::Presenter::Sharing.new(Themes::Presenter::Editor.new(theme), base_url: "http://example.test")
    controller = ApplicationController.new.tap { |instance| instance.request = ActionDispatch::TestRequest.create }
    controller.view_context.render(Components::Editor::ExportDialog.new(presenter: sharing))
  end
end
