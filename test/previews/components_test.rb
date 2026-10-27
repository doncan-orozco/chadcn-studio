require "test_helper"

class PreviewComponentsTest < ActiveSupport::TestCase
  test "TrafficBar renders an accessible meter filled with the chart token" do
    html = Components::Previews::TrafficBar.new(name: "Direct", share: 82, index: 1).call

    assert_includes html, 'role="meter"'
    assert_includes html, 'aria-valuetext="82%"'
    assert_includes html, 'aria-valuenow="82"'
    assert_includes html, 'aria-label="Direct"'
    assert_includes html, "bg-chart-1"
    assert_includes html, "82%"
  end

  test "TrafficBar clamps the share into 0..100" do
    html = Components::Previews::TrafficBar.new(name: "Over", share: 140, index: 2).call

    assert_includes html, 'aria-valuenow="100"'
    assert_includes html, "width: 100%"
  end

  test "TrafficBar rejects an unknown chart index" do
    assert_raises(KeyError) { Components::Previews::TrafficBar.new(name: "X", share: 1, index: 9).call }
  end

  test "Root merges extra attributes into the wrapper" do
    html = Components::Previews::Root.new(page: Phlex::HTML.new, id: "stage", class: "extra").call

    assert_includes html, 'id="stage"'
    assert_includes html, "extra"
    assert_includes html, 'data-testid="preview-root"'
  end
end
