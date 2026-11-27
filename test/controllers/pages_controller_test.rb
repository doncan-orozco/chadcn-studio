require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home offers Create theme as its primary action and leaves the browsing to the header nav" do
    get root_path

    assert_response :success
    assert_select "main a[href=?]", new_theme_path, text: "Create theme"
    assert_select "main a", text: "Browse themes", count: 0
    assert_select "main a", text: "Browse components", count: 0
  end

  test "the header links to the themes list on every page" do
    [ root_path, themes_path, new_theme_path ].each do |path|
      get path

      assert_select "header nav[aria-label=Main] a[href=?]", themes_path, { text: "Themes" }, path
    end
  end

  test "home lists existing themes, each name linking to its editor" do
    get root_path

    assert_response :success
    assert_select "main h2", text: "Your themes"
    Themes::Query::Recent.call.limit(PagesController::HOME_THEMES).each do |theme|
      assert_select "main ul[aria-label='Your themes'] a[href=?]", edit_theme_path(theme), text: theme.name
    end
  end

  test "home puts Create theme right under the intro, before Your themes, so tab and heading order follow" do
    get root_path

    nodes = css_select("main h1, main h2, main a")
    title = nodes.index { |node| node.name == "h1" }
    create = nodes.index { |node| node.name == "a" && node.text.strip == "Create theme" }
    heading = nodes.index { |node| node.name == "h2" && node.text.strip == "Your themes" }

    assert title && create && heading, "expected the h1, Create theme and the Your themes heading on home"
    assert_operator title, :<, create
    assert_operator create, :<, heading
  end

  test "home theme links carry a visible focus style" do
    get root_path

    assert_select "main ul[aria-label='Your themes'] a.focus-visible\\:ring-\\[3px\\].focus-visible\\:outline-none"
  end

  test "home theme links are rows that take the width Export leaves at least 24 px tall, spaced apart" do
    get root_path

    assert_select "main ul[aria-label='Your themes'].space-y-2"
    assert_select "main ul[aria-label='Your themes'] a.flex.flex-1.min-h-8", minimum: 1
  end

  test "home lists at most the five newest themes" do
    extras = Array.new(6) { |i| themes(:zinc).dup.tap { |theme| theme.update!(name: "Extra #{i}", slug: "extra-#{i}") } }

    get root_path

    assert_select "main ul[aria-label='Your themes'] li", PagesController::HOME_THEMES
    assert_select "main ul[aria-label='Your themes'] a", text: "Extra 0", count: 0
    extras.last(PagesController::HOME_THEMES).each do |theme|
      assert_select "main ul[aria-label='Your themes'] a[href=?]", edit_theme_path(theme), text: theme.name
    end
  end

  test "home with no themes has no Your themes list" do
    Theme.destroy_all
    get root_path

    assert_response :success
    assert_select "main h2", text: "Your themes", count: 0
    assert_select "main a[href=?]", new_theme_path, text: "Create theme"
  end

  test "home does not offer describing a theme while generation is off" do
    key = ENV.delete("ANTHROPIC_API_KEY")
    get root_path

    assert_select "main a", text: "Describe a theme", count: 0
    assert_select "main a[href*=generation-prompt]", count: 0
    assert_select "main p", text: /describe/i, count: 0
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end

  test "home offers describing a theme once generation is configured" do
    GenerateThemeJob.client = FakeGenerationClient.new
    get root_path

    assert_select "main a[href=?][data-turbo=false]", new_theme_path(anchor: Components::Editor::GenerationPanel::PROMPT_ID), text: "Describe a theme"
    assert_select "main p", text: /describe a theme/
  ensure
    GenerateThemeJob.client = nil
  end
end
