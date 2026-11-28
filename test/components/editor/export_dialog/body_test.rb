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
    assert_not_includes command.inner_html, "/<wbr>/"
  end

  test "the draft offer says the theme becomes public and can be undone" do
    text = render_body(themes(:zinc)).at_css("[data-testid=export-draft]").text

    assert_match(/anyone with its link/, text)
    assert_match(/unpublish it at any time/, text)
  end

  test "a published theme shows a Published badge and an Unpublish form for the dialog" do
    html = render_body(themes(:slate))
    form = html.at_css("[data-testid=export-unpublish-form]")

    assert_equal "Published", html.at_css("[data-testid=dialog-published]").text.strip
    assert_equal "Unpublish", html.at_css("[data-testid=export-unpublish]").text.strip
    assert_equal "delete", form.at_css("input[name=_method]")["value"]
    assert_equal "export_dialog", form.at_css("input[name=from]")["value"]
    assert_nil form.at_css("input[name=trigger]")
  end

  test "a row's published body sends its compact trigger with Unpublish" do
    sharing = Exports::Presenter::Sharing.new(themes(:slate), base_url: "https://studio.test")
    html = Nokogiri::HTML.fragment(ApplicationController.render(Components::Editor::ExportDialog::Body.new(presenter: sharing, compact: true), layout: false))
    form = html.at_css("[data-testid=export-unpublish-form]")

    assert_equal "delete", form.at_css("input[name=_method]")["value"]
    assert form.at_css("input[name=trigger][value=row]")
  end

  test "a draft theme offers to publish and shows no import command" do
    theme = themes(:zinc)
    html = render_body(theme)
    sharing = Exports::Presenter::Sharing.new(theme, base_url: "https://studio.test")

    assert_not sharing.published?
    assert html.at_css("[data-testid=export-draft]")
    assert html.at_css("[data-testid=export-publish]")
    assert_nil html.at_css("[data-testid=import-command]")
  end

  test "a draft is downloadable right away through the studio's draft export, a published theme through its public URL" do
    draft = render_body(themes(:zinc))
    published = render_body(themes(:slate))

    assert_equal "/t/zinc.css?draft=1", draft.at_css("[data-testid=download-css]")["href"]
    assert_equal "/t/zinc.json?draft=1", draft.at_css("[data-testid=download-json]")["href"]
    assert_equal "theme.css", draft.at_css("[data-testid=download-css]")["download"]
    assert draft.at_css("[data-testid=download-css-status]")
    assert_equal "/t/slate.css", published.at_css("[data-testid=download-css]")["href"]
    assert_equal "/t/slate.json", published.at_css("[data-testid=download-json]")["href"]
  end

  test "a row's draft form tells the server its trigger was compact, the editor's does not" do
    sharing = Exports::Presenter::Sharing.new(themes(:zinc), base_url: "https://studio.test")
    row = Nokogiri::HTML.fragment(ApplicationController.render(Components::Editor::ExportDialog::Body.new(presenter: sharing, compact: true), layout: false))

    assert row.at_css("input[name=trigger][value=row]")
    assert_nil render_body(themes(:zinc)).at_css("input[name=trigger]")
  end
end
