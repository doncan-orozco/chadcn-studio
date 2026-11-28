require "test_helper"

class Themes::PublicationsControllerTest < ActionDispatch::IntegrationTest
  test "POST publishes and goes back to the editor" do
    post theme_publication_path(themes(:zinc))

    assert_redirected_to edit_theme_path(themes(:zinc))
    assert_predicate themes(:zinc).reload, :published?
  end

  test "POST as a Turbo Stream swaps the Export dialog body and the toggle and publishes" do
    post theme_publication_path(themes(:zinc)), params: { from: "export_dialog" }, as: :turbo_stream

    assert_response :success
    assert_predicate themes(:zinc).reload, :published?
    assert_select "turbo-stream[action=replace][target=?] [data-testid=import-command]", "export-dialog-host-#{themes(:zinc).id}"
    assert_select "turbo-stream[action=replace][target=publish-toggle-form] [data-testid=publish-toggle]", /Unpublish/
  end

  test "publishing from the Export dialog also swaps the header badge and link" do
    post theme_publication_path(themes(:zinc)), params: { from: "export_dialog" }, as: :turbo_stream

    assert_select "turbo-stream[action=replace][target=?]", Components::Editor::PublicationState::ID do
      assert_select "[data-testid=publication-state]", text: /\APublished\z/
      assert_select "[data-testid=publication-link][href=?]", "/t/zinc.css"
    end
  end

  test "DELETE from the Export dialog unpublishes and answers with the dialog open on its draft body" do
    delete theme_publication_path(themes(:slate)), params: { from: "export_dialog" }, as: :turbo_stream

    assert_response :success
    assert_not_predicate themes(:slate).reload, :published?
    assert_select "turbo-stream[action=replace][target=?] [data-testid=export-draft]", "export-dialog-host-#{themes(:slate).id}"
    assert_select "turbo-stream[action=replace][target=publish-toggle-form] [data-testid=publish-toggle]", /Publish/
    assert_select "turbo-stream[action=replace][target=?] [data-testid=publication-state]", Components::Editor::PublicationState::ID, /Not published/
  end

  test "unpublishing from a row's dialog answers with the draft body and keeps the row's compact, named trigger" do
    delete theme_publication_path(themes(:slate)), params: { from: "export_dialog", trigger: "row" }, as: :turbo_stream

    assert_response :success
    assert_not_predicate themes(:slate).reload, :published?
    host = Components::Editor::ExportDialog.host_id(themes(:slate).id)

    assert_select "turbo-stream[target=?] [data-testid=export-draft]", host
    assert_select "turbo-stream[target=?] button[aria-label=?]", host, "Export #{themes(:slate).name}"
  end

  test "DELETE without the dialog still redirects to the editor" do
    delete theme_publication_path(themes(:slate))

    assert_redirected_to edit_theme_path(themes(:slate))
    assert_not_predicate themes(:slate).reload, :published?
  end

  test "publishing an invalid theme from the Export dialog answers 422 HTML with the errors" do
    themes(:zinc).update_column(:light, themes(:zinc).light.except("primary"))

    post theme_publication_path(themes(:zinc)), params: { from: "export_dialog" }, as: :turbo_stream

    assert_response :unprocessable_entity
    assert_equal "text/html", response.media_type
    assert_select "[data-testid=editor-errors]", /primary/i
    assert_not_predicate themes(:zinc).reload, :published?
  end

  test "DELETE unpublishes and the public URL answers 404" do
    delete theme_publication_path(themes(:slate))

    assert_redirected_to edit_theme_path(themes(:slate))
    get theme_export_path("slate", format: "css")

    assert_response :not_found
  end

  test "an unknown theme is 404" do
    post theme_publication_path(0)

    assert_response :not_found
  end

  test "publishing an invalid theme renders the editor with 422 and stays a draft" do
    themes(:zinc).update_column(:light, themes(:zinc).light.except("primary"))

    post theme_publication_path(themes(:zinc))

    assert_response :unprocessable_entity
    assert_select "[data-testid=editor-errors]", /primary/i
    assert_not_predicate themes(:zinc).reload, :published?
  end

  test "unpublishing an invalid theme renders the editor with 422 and stays published" do
    themes(:slate).update_column(:light, themes(:slate).light.except("primary"))

    delete theme_publication_path(themes(:slate))

    assert_response :unprocessable_entity
    assert_select "[data-testid=editor-errors]", /primary/i
    assert_predicate themes(:slate).reload, :published?
  end

  test "publishing from a row's dialog keeps the row's compact, named trigger" do
    post theme_publication_path(themes(:zinc)), params: { from: "export_dialog", trigger: "row" }, as: :turbo_stream

    assert_select "turbo-stream[target=?] button[aria-label=?]", Components::Editor::ExportDialog.host_id(themes(:zinc).id), "Export Zinc"
  end

  test "publishing from the editor's dialog keeps its plain trigger" do
    post theme_publication_path(themes(:zinc)), params: { from: "export_dialog" }, as: :turbo_stream

    assert_select "turbo-stream[target=?] button[data-testid=export]:not([aria-label])", Components::Editor::ExportDialog.host_id(themes(:zinc).id)
  end
end
