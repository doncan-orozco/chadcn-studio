require "application_system_test_case"

class ExportsTest < ApplicationSystemTestCase
  test "a draft has no export links, publishing makes them appear" do
    visit edit_theme_path(themes(:zinc))

    click_on "Export"

    assert_selector :testid, "export-draft"
    assert_no_selector :testid, "download-css"
    send_keys :escape

    click_on "Publish"

    assert_text "Theme published"
    assert_selector :testid, "publish-toggle", text: "Unpublish"

    click_on "Export"

    assert_selector :testid, "download-css"
    assert_selector :testid, "download-json"
    assert_match(%r{\Abin/rails theme:import\[http://.+/t/zinc\.css\]\z}, find(:testid, "import-command").value)
  end

  test "a draft publishes from inside the dialog and the dialog stays open" do
    visit edit_theme_path(themes(:zinc))

    click_on "Export"
    click_on "Publish and show import command"

    assert_selector :testid, "export-panel"
    assert_selector :testid, "download-css"
    assert_match(%r{\Abin/rails theme:import\[http://.+/t/zinc\.css\]\z}, find(:testid, "import-command").value)
    assert_predicate themes(:zinc).reload, :published?
    send_keys :escape

    assert_no_selector :testid, "export-panel"
    assert_selector :testid, "publish-toggle", text: "Unpublish"

    click_on "Export"

    assert_selector :testid, "download-css"
    assert_no_selector :testid, "export-draft"
  end

  test "unpublishing takes the theme off its URL" do
    visit edit_theme_path(themes(:slate))

    click_on "Unpublish"

    assert_text "Theme unpublished"
    click_on "Export"

    assert_selector :testid, "export-draft"
  end
end
