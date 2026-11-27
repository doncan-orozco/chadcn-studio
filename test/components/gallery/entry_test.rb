require "test_helper"

class Components::Gallery::EntryTest < ActiveSupport::TestCase
  setup { @entry = Chadcn::Catalog::Entry.new(component: "solo", title: "Solo", scenario_id: "x", scenario_count: 1, tree: { "c" => "_div" }.freeze) }

  def render_entry(**attrs)
    Nokogiri::HTML5.fragment(Components::Gallery::Entry.new(entry: @entry, anchor: "solo", **attrs).call)
  end

  test "keeps its id and test id by default" do
    section = render_entry.at_css("section")

    assert_equal "solo", section["id"]
    assert_equal "gallery-entry", section["data-testid"]
  end

  test "merges extra data attributes into the root" do
    section = render_entry(data: { gallery__index_spy_target: "entry" }).at_css("section")

    assert_equal "solo", section["id"]
    assert_equal "gallery-entry", section["data-testid"]
    assert_equal "entry", section["data-gallery--index-spy-target"]
  end

  test "shows only the title above the demo, with no scenario count" do
    section = render_entry.at_css("section")

    assert_equal "Solo", section.at_css("h3").text
    assert_no_match(/scenario/i, section.text)
  end
end
