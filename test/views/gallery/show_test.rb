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

  test "the spy is wired once, on the index, which is the only place that names it" do
    assert_equal 1, @html.css("[data-controller~='gallery--index-spy']").size
    assert_equal 1, @html.css("nav[aria-label=Components][data-controller~='gallery--index-spy']").size
  end
end
