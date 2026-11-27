require "test_helper"

class Components::Gallery::IndexTest < ActiveSupport::TestCase
  setup do
    @presenter = Gallery::Presenter::Index.new
    @html = Nokogiri::HTML5.fragment(Components::Gallery::Index.new(@presenter).call)
  end

  test "the index has a labelled filter field wired to the filter controller, with a status line" do
    assert_equal "Find a component", @html.at_css("nav[aria-label=Components] label[for=gallery-filter]").text.strip
    assert @html.at_css("nav[aria-label=Components] input#gallery-filter[type=search][data-editor--variable-filter-target=query]")
    assert @html.at_css("nav[aria-label=Components] [role=status][data-editor--variable-filter-target=status]")
    assert_not_includes @html.at_css("input#gallery-filter")["data-action"], ":stop"
  end

  test "the nav is the filter's scroll container and names its empty state" do
    nav = @html.at_css("nav[aria-label=Components]")

    assert_equal %w[editor--variable-filter gallery--index-spy], nav["data-controller"].split
    assert_equal "No component matches", nav["data-editor--variable-filter-empty-label-value"]
  end

  test "every component is a filterable row keyed by the presenter, linking to its anchor" do
    @presenter.entries.each do |entry|
      assert @html.at_css("section li[data-editor--variable-filter-target=row][data-variable='#{@presenter.filter_key(entry)}'] a[href='##{entry.component}']")
    end
  end

  test "rows are grouped under their letters, in the presenter's order" do
    letters = @html.css("section > p[data-testid=gallery-index-letter]").map { |letter| letter.text.strip }

    assert_equal @presenter.groups.map(&:letter), letters
  end

  test "the nav binds scroll and resize to the spy passively" do
    actions = @html.at_css("nav[aria-label=Components]")["data-action"].split

    assert_includes actions, "scroll@window->gallery--index-spy#schedule:passive"
    assert_includes actions, "resize@window->gallery--index-spy#schedule:passive"
  end

  test "every link is a spy target and none starts marked" do
    links = @html.css("a[data-gallery--index-spy-target=link]")

    assert_equal @presenter.entries.size, links.size
    assert_empty @html.css("a[aria-current]")
  end

  test "a presenter with other entries renders only those" do
    entry = @presenter.entries.first
    html = Nokogiri::HTML5.fragment(Components::Gallery::Index.new(Gallery::Presenter::Index.new(entries: [ entry ])).call)

    assert_equal 1, html.css("li").size
  end
end
