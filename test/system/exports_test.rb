require "application_system_test_case"

class ExportsTest < ApplicationSystemTestCase
  test "a draft has no export links, publishing makes them appear" do
    visit edit_theme_path(themes(:zinc))

    click_on "Export"

    assert_selector :testid, "export-draft"
    assert_no_selector :testid, "download-css"
    send_keys :escape

    assert_selector :testid, "publication-state", text: "Not published"
    click_on "Publish"

    assert_text "Theme published"
    assert_selector :testid, "publication-state", text: "Published"
    assert_selector :testid, "publication-link"
    assert_selector :testid, "publish-toggle", text: "Unpublish"

    click_on "Export"

    assert_selector :testid, "download-css"
    assert_selector :testid, "download-json"
    assert_match(%r{\Abin/rails theme:import\[http://.+/t/zinc\.css\]\z}, find(:testid, "import-command").text)
  end

  test "a draft publishes from inside the dialog and the dialog stays open" do
    visit edit_theme_path(themes(:zinc))

    click_on "Export"
    click_on "Publish and show import command"

    assert_selector :testid, "export-panel"
    assert_selector :testid, "download-css"
    assert_match(%r{\Abin/rails theme:import\[http://.+/t/zinc\.css\]\z}, find(:testid, "import-command").text)
    assert_predicate themes(:zinc).reload, :published?
    send_keys :escape

    assert_no_selector :testid, "export-panel"
    assert_selector :testid, "publish-toggle", text: "Unpublish"

    click_on "Export"

    assert_selector :testid, "download-css"
    assert_no_selector :testid, "export-draft"
  end

  test "the import command shows in full and a Copy button confirms the copy" do
    visit edit_theme_path(themes(:slate))

    click_on "Export"
    command = find(:testid, "import-command")

    assert_match(%r{\Abin/rails theme:import\[http://.+/t/slate\.css\]\z}, command.text)
    assert_operator command.native.property("scrollWidth"), :<=, command.native.property("clientWidth")
    click_on "Copy"

    assert_selector :testid, "import-copy", text: "Copied"
    assert_selector :testid, "import-copy-status", text: "Copied", visible: :all
    assert_selector :testid, "import-copy", text: "Copy", exact_text: true, wait: 5
  end

  test "the CSS download is labelled and saved as theme.css, and the dialog says it was downloaded" do
    visit edit_theme_path(themes(:slate))

    click_on "Export"
    link = find(:testid, "download-css")

    assert_equal "Download theme.css", link.text
    assert_equal "theme.css", link[:download]
    assert_no_selector :testid, "download-css-status", text: "Downloaded", visible: :all
    link.click

    assert_selector :testid, "download-css-status", text: "Downloaded theme.css"
    click_on "Copy"

    assert_selector :testid, "import-copy", text: "Copied"
    assert_selector :testid, "import-copy", text: "Copy", exact_text: true, wait: 5
    assert_selector :testid, "download-css-status", text: "Downloaded theme.css"
  end

  test "the download line goes away when the dialog closes" do
    visit edit_theme_path(themes(:slate))

    click_on "Export"
    find(:testid, "download-css").click

    assert_selector :testid, "download-css-status", text: "Downloaded theme.css"
    send_keys :escape

    assert_no_selector :testid, "export-panel"
    click_on "Export"

    assert_selector :testid, "download-css"
    assert_no_selector :testid, "download-css-status", text: "Downloaded", visible: :all
  end

  test "unpublishing takes the theme off its URL" do
    visit edit_theme_path(themes(:slate))

    click_on "Unpublish"

    assert_text "Theme unpublished"
    assert_selector :testid, "publication-state", text: "Not published"
    click_on "Export"

    assert_selector :testid, "export-draft"
  end
end
