require "test_helper"

class Components::Editor::VariableFilterTest < ActiveSupport::TestCase
  setup do
    @html = Nokogiri::HTML5.fragment(Components::Editor::VariableFilter.new.call)
    @actions = @html.at_css("input")["data-action"].split
  end

  test "renders a labelled search field wired to the filter controller, with a status line" do
    assert_equal "Find a variable", @html.at_css("label[for=variable-filter]").text.strip
    assert @html.at_css("input#variable-filter[type=search][data-editor--variable-filter-target=query]")
    assert @html.at_css("[role=status][data-editor--variable-filter-target=status]")
  end

  test "its events stop at the filter, so a query never reaches the form's dirty tracking" do
    assert_includes @actions, "input->editor--variable-filter#filter:stop"
    assert_includes @actions, "change->editor--variable-filter#filter:stop"
    assert_includes @actions, "keydown.enter->editor--variable-filter#preventSubmit"
  end
end
