require "test_helper"

class Components::Editor::VariableFilterTest < ActiveSupport::TestCase
  test "renders a labelled search field wired to the filter controller, with a status line" do
    html = Components::Editor::VariableFilter.new.call

    assert_includes html, "Find a variable"
    assert_includes html, 'type="search"'
    assert_includes html, "input->editor--variable-filter#filter:stop"
    assert_includes html, 'role="status"'
  end

  test "its events stop at the filter, so a query never reaches the form's dirty tracking" do
    html = Components::Editor::VariableFilter.new.call

    assert_includes html, "input->editor--variable-filter#filter:stop"
    assert_includes html, "change->editor--variable-filter#filter:stop"
  end
end
