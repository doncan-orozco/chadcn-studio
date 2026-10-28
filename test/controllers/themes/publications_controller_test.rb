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
end
