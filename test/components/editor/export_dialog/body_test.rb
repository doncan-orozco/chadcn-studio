require "test_helper"

class Components::Editor::ExportDialog::BodyTest < ActiveSupport::TestCase
  def render_body(theme)
    sharing = Exports::Presenter::Sharing.new(theme, base_url: "https://studio.test")
    Nokogiri::HTML.fragment(ApplicationController.render(Components::Editor::ExportDialog::Body.new(presenter: sharing), layout: false))
  end

  test "the import command sits on its own row, Copy below it" do
    html = render_body(themes(:slate))
    command = html.at_css("[data-testid=import-command]")
    copy = html.at_css("[data-testid=import-copy]")

    assert_not_includes command.ancestors.first.name, "button"
    assert_not_equal command.parent, copy.parent, "the command and Copy share a row"
    assert_no_match(/\bflex-1\b/, command["class"])
  end

  test "the command may wrap only between tokens, never inside a file name" do
    html = render_body(themes(:slate))
    command = html.at_css("[data-testid=import-command]")

    assert_no_match(/break-all/, command["class"])
    assert_equal "bin/rails theme:import[https://studio.test/t/slate.css]", command.text
    assert_operator command.css("wbr").size, :>=, 3
    assert_no_match(%r{slate\.<wbr|sla<wbr|\.<wbr>css}, command.inner_html)
    assert_includes command.inner_html, "slate.css]"
  end
end
