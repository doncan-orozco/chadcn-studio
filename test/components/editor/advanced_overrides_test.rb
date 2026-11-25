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

  test "each field shows a swatch beside it, the derived color as hex in the placeholder, and says Close keeps what was typed" do
    html = Components::Editor::AdvancedOverrides.new(group: @group).call
    rows = @group.overrides("light").size + @group.overrides("dark").size

    assert_equal rows, html.scan('data-testid="override-swatch"').size
    assert_equal rows, html.scan('data-controller="editor--override-swatch"').size
    assert_equal rows, html.scan(/aria-hidden="true"[^>]*data-testid="override-swatch"|data-testid="override-swatch"[^>]*aria-hidden="true"/).size
    assert_match(/placeholder="#\h{6}"/, html)
    refute_match(/placeholder="oklch/, html)
    assert_includes html, "Closing this panel keeps what you typed"
  end
end
