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
end
