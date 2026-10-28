require "test_helper"

class ThemesControllerTest < ActionDispatch::IntegrationTest
  test "GET /themes lists a card per theme with a swatch strip" do
    get themes_path

    assert_response :success
    assert_select "[data-testid=theme-card]", Theme.count
    assert_select "[data-testid=theme-card] [role=img] span", Theme.count * Themes::Presenter::Card::SWATCHES.size
  end

  test "GET /themes with no themes shows the empty state" do
    Theme.destroy_all
    get themes_path

    assert_response :success
    assert_select "[data-testid=theme-card]", 0
    assert_includes response.body, "No themes yet"
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
  end

  test "GET /themes/:id shows the palette, light and dark" do
    get theme_path(themes(:zinc))

    assert_response :success
    assert_select "h1", "Zinc"
    assert_select "[data-testid=palette] tbody tr", Chadcn::Theme::REQUIRED.size + Chadcn::Theme::ROOT_ONLY.size
  end

  test "GET /themes/:id for an unknown id is 404" do
    get theme_path(0)

    assert_response :not_found
  end

  test "DELETE /themes/:id removes the theme and goes back to the list" do
    assert_difference("Theme.count", -1) { delete theme_path(themes(:zinc)) }

    assert_redirected_to themes_path
  end
end
