require "test_helper"

class Themes::PublicationsControllerTest < ActionDispatch::IntegrationTest
  test "POST publishes and goes back to the editor" do
    post theme_publication_path(themes(:zinc))

    assert_redirected_to edit_theme_path(themes(:zinc))
    assert_predicate themes(:zinc).reload, :published?
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
end
