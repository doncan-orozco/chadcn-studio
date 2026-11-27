require "test_helper"

class Components::Shared::ListFilterTest < ActiveSupport::TestCase
  def render_filter(**options)
    Nokogiri::HTML5.fragment(
      Components::Shared::ListFilter.new(id: "x", label: "Find a thing", placeholder: "a, b...", wrapper: "grid", **options).call
    )
  end

  test "wires the given id, label and placeholder to the filter controller, with a status line" do
    html = render_filter

    assert_equal "Find a thing", html.at_css("label[for=x]").text.strip
    assert html.at_css("input#x[type=search][placeholder='a, b...'][data-editor--variable-filter-target=query]")
    assert html.at_css("div.grid [role=status][data-editor--variable-filter-target=status]")
  end

  test "by default the events are not stopped" do
    actions = render_filter.at_css("input")["data-action"].split

    assert_includes actions, "input->editor--variable-filter#filter"
    assert_includes actions, "change->editor--variable-filter#filter"
    assert_includes actions, "keydown.enter->editor--variable-filter#preventSubmit"
  end

  test "isolated stops the input and change events" do
    actions = render_filter(isolated: true).at_css("input")["data-action"].split

    assert_includes actions, "input->editor--variable-filter#filter:stop"
    assert_includes actions, "change->editor--variable-filter#filter:stop"
    assert_includes actions, "keydown.enter->editor--variable-filter#preventSubmit"
  end
end
