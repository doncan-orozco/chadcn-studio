require "test_helper"

# The sidebar of the editor: the groups, and the generation panel only when the studio can generate.
class Views::Themes::Edit::GroupsTest < ActionDispatch::IntegrationTest
  test "a studio that cannot generate shows the groups and no setup line" do
    key = ENV.delete("ANTHROPIC_API_KEY")
    get edit_theme_path(themes(:slate))

    assert_select "[data-testid=groups]"
    assert_select "[data-testid=generation-status], [data-testid=generation-form]", count: 0
    assert_no_match(/ANTHROPIC_API_KEY/, response.body)
  ensure
    ENV["ANTHROPIC_API_KEY"] = key if key
  end

  test "a studio that can generate shows the prompt form in the sidebar" do
    GenerateThemeJob.client = FakeGenerationClient.new
    get edit_theme_path(themes(:slate))

    assert_select "[data-testid=groups] [data-testid=generation-form]"
  ensure
    GenerateThemeJob.client = nil
  end
end
