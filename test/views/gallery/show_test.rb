require "test_helper"

class Views::Gallery::ShowTest < ActiveSupport::TestCase
  setup { @html = Nokogiri::HTML5.fragment(Views::Gallery::Show.new(Gallery::Presenter::Index.new).call) }

  test "the page renders the index beside the content" do
    assert @html.at_css("nav[aria-label=Components] input#gallery-filter")
    assert_equal Chadcn::Catalog.entries.size, @html.css("nav[aria-label=Components] a[data-gallery--index-spy-target=link]").size
  end

  test "the index letters match the content's letter groups" do
    index_letters = @html.css("nav[aria-label=Components] section > p[data-testid=gallery-index-letter]").map { |letter| letter.text.strip }
    content_letters = @html.css("section[aria-label^='Components starting'] > h2").map { |heading| heading.text.strip }

    assert_equal content_letters, index_letters
  end

  test "the spy is mounted once, on the page wrapper, with passive scroll and resize actions" do
    spies = @html.css("[data-controller~='gallery--index-spy']")

    assert_equal 1, spies.size
    assert_empty spies.first.css("nav[aria-label=Components][data-controller~='gallery--index-spy']")
    assert_not_nil spies.first.at_css("nav[aria-label=Components]")
    assert_not_nil spies.first.at_css("[data-testid=gallery-entry]")
    assert_equal %w[scroll@window->gallery--index-spy#schedule:passive resize@window->gallery--index-spy#schedule:passive], spies.first["data-action"].split
  end

  test "every entry is a spy target whose id a link points to" do
    ids = @html.css("section[data-gallery--index-spy-target=entry]").map { |entry| entry["id"] }
    fragments = @html.css("nav a[data-gallery--index-spy-target=link]").map { |link| link["href"].delete_prefix("#") }

    assert_equal Chadcn::Catalog.entries.size, ids.size
    assert_equal fragments.sort, ids.sort
  end
end
