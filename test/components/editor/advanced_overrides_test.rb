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

  test "each field has a decorative swatch wired to the swatch controller" do
    page = Capybara.string(Components::Editor::AdvancedOverrides.new(group: @group).call)
    rows = @group.overrides("light").size + @group.overrides("dark").size

    assert page.has_css?("[data-controller='editor--override-swatch'] [data-testid='override-swatch'][aria-hidden='true']", count: rows)
    assert page.has_css?("input[data-editor--override-swatch-target='input']", count: rows)
  end

  test "placeholders are the derived color as hex, never oklch" do
    html = Components::Editor::AdvancedOverrides.new(group: @group).call

    assert_match(/placeholder="#\h{6}"/, html)
    refute_match(/placeholder="oklch/, html)
  end

  test "the panel says that closing keeps what was typed" do
    assert_includes Components::Editor::AdvancedOverrides.new(group: @group).call, "Closing this panel keeps what you typed"
  end
end
