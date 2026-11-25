require "test_helper"

class Components::Editor::VariableFilterTest < ActiveSupport::TestCase
  test "renders a labelled search field wired to the filter controller, with a status line" do
    html = Components::Editor::VariableFilter.new.call

    assert_includes html, "Find a variable"
    assert_includes html, 'type="search"'
    assert_includes html, "input-&gt;editor--variable-filter#filter"
    assert_includes html, 'role="status"'
  end
end
