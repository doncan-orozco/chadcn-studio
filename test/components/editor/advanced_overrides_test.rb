require "test_helper"

class Components::Editor::AdvancedOverridesTest < ActiveSupport::TestCase
  setup { @group = Themes::Presenter::Group.new(themes(:zinc), key: "advanced") }

  test "every field is a filterable row named by its variable, primary first" do
    html = Components::Editor::AdvancedOverrides.new(group: @group).call
    names = html.scan(/data-variable="([^"]+)"/).flatten

    assert_equal %w[primary border ring], names.first(3)
    assert_includes html, 'data-editor--variable-filter-target="row"'
    assert_equal @group.overrides("light").size + @group.overrides("dark").size, names.size
  end

  test "each field is labelled in words with the CSS name beside it" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)
    label = page.find("label[for='override-light-border']")

    assert_includes label.text, "Borders"
    assert_includes label.find("span.font-mono").text, "--border"
  end

  test "each field has a decorative swatch wired to the swatch controller" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)
    rows = @group.overrides("light").size + @group.overrides("dark").size

    assert page.has_css?("[data-controller='editor--override-swatch'] [data-testid='override-swatch'][aria-hidden='true']", count: rows, visible: :all)
    assert page.has_css?("input[data-editor--override-swatch-target='input']", count: rows, visible: :all)
  end

  test "placeholders are the derived color as hex, except the translucent ones hex cannot say" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)

    assert_match(/\A#\h{6}\z/, page.find_by_id("override-light-border")[:placeholder])
    assert_match(%r{\Aoklch\(.+/ \d+%\)\z}, page.find_by_id("override-dark-border", visible: :all)[:placeholder])
  end

  test "opens on Light with a Light and Dark switch, and keeps both modes' fields in the form" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)

    assert_equal %w[Light Dark], page.all("[role=tab]").map(&:text)
    assert_equal "true", page.find("[data-testid=overrides-mode-light]")["aria-selected"]
    assert page.has_css?("[role=tabpanel][data-state=active] [data-testid=override-row]", count: @group.overrides("light").size)
    assert page.has_css?("[role=tabpanel][data-state=inactive] input#override-dark-border", visible: :all)
  end

  test "fields sit under the names of the sidebar groups, in the sidebar's order" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)
    headings = page.all("[role=tabpanel][data-state=active] h3").map(&:text)

    assert_equal [ "Most used", "Brand color", "Backgrounds, cards and text", "Radius", "Charts", "Sidebar" ], headings
  end

  test "gives one instruction line, not two paragraphs" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)

    assert_equal 1, page.all("p").size
  end

  test "the panel says Close keeps the overrides and Save stores them" do
    html = Components::Editor::AdvancedOverrides.new(group: @group).call

    assert_includes html, "Closing this panel keeps your overrides"
    assert_includes html, "Save the theme to store them"
  end
end
