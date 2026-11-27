require "test_helper"

class Views::Gallery::ShowTest < ActiveSupport::TestCase
  setup { @html = Nokogiri::HTML5.fragment(Views::Gallery::Show.new(Gallery::Presenter::Index.new).call) }

  test "the index has a labelled filter field wired to the filter controller, with a status line" do
    assert_equal "Find a component", @html.at_css("nav[aria-label=Components] label[for=gallery-filter]").text.strip
    assert @html.at_css("nav[aria-label=Components] input#gallery-filter[type=search][data-editor--variable-filter-target=query]")
    assert @html.at_css("nav[aria-label=Components] [role=status][data-editor--variable-filter-target=status]")
    assert_includes @html.at_css("input#gallery-filter")["data-action"], "keydown.enter->editor--variable-filter#preventSubmit"
  end

  test "every component is a filterable row named in lower case, grouped by letter like the content" do
    Chadcn::Catalog.entries.each do |entry|
      assert @html.at_css("nav[aria-label=Components] section li[data-editor--variable-filter-target=row][data-variable='#{entry.title.downcase}'] a[href='##{entry.component}']")
    end
    index_letters = @html.css("nav[aria-label=Components] section > p[data-testid=gallery-index-letter]").map { |letter| letter.text.strip }
    content_letters = @html.css("section[aria-label^='Components starting'] > h2").map { |heading| heading.text.strip }

    assert_equal content_letters, index_letters
  end

  test "the page wires the current-entry marker to every index link and starts with none marked" do
    assert_equal 1, @html.css("[data-controller~='gallery--index-spy']").size
    assert_equal Chadcn::Catalog.entries.size, @html.css("nav[aria-label=Components] a[data-gallery--index-spy-target=link]").size
    assert_empty @html.css("nav[aria-label=Components] a[aria-current]")
  end

  test "the marked link is styled by more than color" do
    classes = @html.at_css("nav[aria-label=Components] a")["class"]

    assert_includes classes, "aria-[current=location]:font-medium"
    assert_includes classes, "aria-[current=location]:bg-accent"
  end
end
