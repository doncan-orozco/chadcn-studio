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

  test "another list can name its own field and drop the stop modifier" do
    html = Components::Editor::VariableFilter.new(id: "x", label: "Find a thing", placeholder: "a, b...", stop: false).call

    assert_includes html, 'id="x"'
    assert_includes html, "Find a thing"
    assert_includes html, "input->editor--variable-filter#filter "
    assert_not_includes html, ":stop"
    assert_includes html, "keydown.enter->editor--variable-filter#preventSubmit"
  end
end
