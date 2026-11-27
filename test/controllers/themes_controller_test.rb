require "test_helper"

class ThemesControllerTest < ActionDispatch::IntegrationTest
  test "GET /themes lists a card per theme with a swatch strip" do
    get themes_path

    assert_response :success
    assert_select "[data-testid=theme-card]", Theme.count
    assert_select "[data-testid=theme-card] a[href=?]", edit_theme_path(themes(:zinc)), text: "Zinc"
    assert_select "[data-testid=theme-card] [role=img] span", Theme.count * Themes::Presenter::Card::SWATCHES.size
  end

  test "GET /themes makes New theme the primary while themes exist" do
    get themes_path

    assert_select "main a[href=?][data-variant=default]", new_theme_path, text: "New theme"
  end

  test "GET /themes keeps New theme primary on the empty state" do
    Theme.destroy_all
    get themes_path

    assert_select "main a[href=?][data-variant=default]", new_theme_path, text: "New theme"
  end

  test "GET /themes with no themes shows the empty state" do
    Theme.destroy_all
    get themes_path

    assert_response :success
    assert_select "[data-testid=theme-card]", 0
    assert_includes response.body, "No themes yet"
  end

  test "GET /themes does not offer describing a theme while generation is off" do
    key = ENV.delete("ANTHROPIC_API_KEY")
    get themes_path

    assert_select "main a", text: "Describe a theme", count: 0
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end

  test "GET /themes offers describing a theme once generation is configured" do
    GenerateThemeJob.client = FakeGenerationClient.new
    get themes_path

    assert_select "main a[href=?]", new_theme_path(anchor: "describe"), text: "Describe a theme"
  ensure
    GenerateThemeJob.client = nil
  end

  test "GET /themes/new shows only the not-set-up line while generation is off" do
    key = ENV.delete("ANTHROPIC_API_KEY")
    get new_theme_path

    assert_select "#describe #generation_status", text: /not set up/
    assert_select "#describe form", count: 0
    assert_no_match(/Claude picks the colors/, response.body)
    assert_no_match(/Or describe it/, response.body)
    assert_select "#describe input, #describe [data-testid=generate]", count: 0
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end

  test "GET /themes/new offers the prompt and Generate once generation is configured" do
    GenerateThemeJob.client = FakeGenerationClient.new
    get new_theme_path

    assert_select "#describe form input[name=?]:not([disabled])", "generation[prompt]"
    assert_select "#describe button[data-testid=generate]:not([disabled])"
    assert_match(/Claude picks the colors/, response.body)
    assert_match(/Or describe it/, response.body)
  ensure
    GenerateThemeJob.client = nil
  end

  test "GET /themes/new asks for a name and a primary color" do
    get new_theme_path

    assert_response :success
    assert_select "form[action='#{themes_path}'] input[name='theme[name]']"
    assert_select "form[action='#{themes_path}'] input[name='theme[primary]']"
  end

  test "POST /themes saves a derived theme and redirects to the editor" do
    assert_difference("Theme.count", 1) { post themes_path, params: { theme: { name: "Ocean", primary: "oklch(0.55 0.2 250)" } } }

    assert_redirected_to edit_theme_path(Theme.find_by!(slug: "ocean"))
  end

  test "POST /themes with a hex brand color stores that color, not a default" do
    post themes_path, params: { theme: { name: "Acme", primary: "#1d4ed8" } }

    theme = Theme.find_by!(slug: "acme")

    assert_redirected_to edit_theme_path(theme)
    assert_equal "oklch(0.488 0.217 264.376)", theme.light["primary"]
  end

  test "GET /themes/new shows a hex example and no prefilled color" do
    get new_theme_path

    assert_select "input[name='theme[primary]'][placeholder='#1d4ed8']:not([value])"
    assert_select "#theme-primary-description", text: /#1d4ed8/
  end

  test "GET /themes/new marks both fields as required and says what the star means" do
    get new_theme_path

    assert_select "label[for='theme-name'] span[aria-hidden='true']", text: "*"
    assert_select "label[for='theme-primary'] span[aria-hidden='true']", text: "*"
    assert_select "input[name='theme[name]'][required]"
    assert_select "input[name='theme[primary]'][required]"
    assert_select "[data-testid=required-legend]", text: /Required/
  end

  test "POST /themes with a color that is neither hex nor oklch says what to type, once" do
    post themes_path, params: { theme: { name: "Bad", primary: "blue" } }

    assert_response :unprocessable_entity
    assert_select "#theme-primary-error", text: "must be a hex color such as #1d4ed8, or an oklch(...) value"
    assert_select "#theme-primary-description", count: 0
    assert_select "input[name='theme[primary]'][value=blue]"
  end

  test "POST /themes with an out-of-range color re-renders the form with the error" do
    assert_no_difference("Theme.count") { post themes_path, params: { theme: { name: "Bad", primary: "oklch(2 0.2 250)" } } }

    assert_response :unprocessable_entity
    assert_select "[data-testid=new-theme-form] [id='theme-primary-error']"
    assert_select "input[name='theme[name]'][value=Bad]"
  end

  test "POST /themes without a primary re-renders the form with 422" do
    assert_no_difference("Theme.count") { post themes_path, params: { theme: { name: "Half" } } }

    assert_response :unprocessable_entity
    assert_select "[id='theme-primary-error']"
    assert_select "[data-testid=required-legend]"
    assert_select "label[for='theme-name'] span[aria-hidden='true']", text: "*"
  end

  test "GET /themes/:id/edit names the page with one h1 and the fixtures with h2" do
    get edit_theme_path(themes(:zinc))

    assert_response :success
    assert_select "h1", count: 1, text: "Edit Zinc"
    assert_select "[data-testid=preview-root] h2", minimum: 1
  end

  test "GET /themes/:id/edit says a draft is not published" do
    get edit_theme_path(themes(:zinc))

    assert_select "[data-testid=publication-state]", text: /Not published/
    assert_select "[data-testid=publication-link]", 0
  end

  test "GET /themes/:id/edit says a published theme is published and links its public URL" do
    get edit_theme_path(themes(:slate))

    assert_select "[data-testid=publication-state]", text: /Published/
    assert_select "[data-testid=publication-link][href=?]", "/t/slate.css"
  end

  test "GET /themes/:id/edit puts the theme name in the document title" do
    get edit_theme_path(themes(:zinc))

    assert_select "title", text: "Edit Zinc - Chadcn Studio"
  end

  test "GET /themes/:id shows the palette, light and dark" do
    get theme_path(themes(:zinc))

    assert_response :success
    assert_select "h1", "Zinc"
    assert_select "a[href='#{edit_theme_path(themes(:zinc))}'][data-variant=default]", "Preview and edit"
    assert_select "button[data-variant=destructive]", 1 # only the dialog's confirm; the page's own actions are not destructive
    assert_select "template button[data-variant=destructive][data-testid=confirm-delete]"
    assert_select "button[aria-label='Delete Zinc'][data-variant=outline].text-destructive", "Delete"
    assert_select "[data-testid=palette] tbody tr", Chadcn::Theme::REQUIRED.size + Chadcn::Theme::ROOT_ONLY.size
  end

  test "GET /themes/:id swatches carry a border that shows on both backgrounds" do
    get theme_path(themes(:zinc))

    assert_select "[data-testid=palette] span.border.border-foreground\\/40[aria-hidden=true]"
  end

  test "GET /themes/:id for an unknown id is 404" do
    get theme_path(0)

    assert_response :not_found
  end

  test "DELETE /themes/:id removes the theme and goes back to the list" do
    assert_difference("Theme.count", -1) { delete theme_path(themes(:zinc)) }

    assert_redirected_to themes_path
  end

  test "after DELETE the list names the deleted theme in a status, once" do
    delete theme_path(themes(:zinc))
    follow_redirect!

    assert_select "[role=status][data-testid=deleted-status]", text: "Zinc deleted"

    get themes_path

    assert_select "[data-testid=deleted-status]", count: 0
  end

  test "the list has no deleted status by default" do
    get themes_path

    assert_select "[data-testid=deleted-status]", count: 0
  end

  test "PATCH /themes/:id names the saved theme in the toast" do
    theme = themes(:zinc)
    patch theme_path(theme), params: { theme: { name: "Ocean" } }

    assert_redirected_to edit_theme_path(theme)
    assert_equal "Ocean saved: renamed from Zinc", flash[:notice]
  end

  test "GET /themes/:id/edit reads Save theme and renders the unsaved marker hidden" do
    get edit_theme_path(themes(:zinc))

    assert_select "button[data-testid=save]", text: "Save theme"
    assert_select "[role=status] [data-testid=unsaved][hidden]", text: "Unsaved changes"
    assert_select "[role=status] [data-testid=saved]:not([hidden])", text: "Saved"
  end

  test "PATCH /themes/:id rejected re-renders the editor with the unsaved marker visible" do
    patch theme_path(themes(:zinc)), params: { theme: { name: "Zinc", inputs: { primary: "oklch(2 0.2 250)" } } }

    assert_response :unprocessable_entity
    assert_select "[data-testid=unsaved]:not([hidden])", text: "Unsaved changes"
    assert_select "[data-testid=saved][hidden]", text: "Saved"
  end

  test "PATCH /themes/:id escapes a markup name in the toast" do
    theme = themes(:zinc)
    patch theme_path(theme), params: { theme: { name: "<b>x</b>" } }
    follow_redirect!

    assert_includes response.body, "&lt;b&gt;x&lt;/b&gt; saved: renamed from Zinc"
    assert_select "b", 0
  end
end
