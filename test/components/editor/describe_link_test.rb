require "test_helper"

class Components::Editor::DescribeLinkTest < ActiveSupport::TestCase
  test "links to the prompt field and skips Turbo so the browser focuses it" do
    link = Nokogiri::HTML5.fragment(ApplicationController.render(Components::Editor::DescribeLink.new, layout: false)).at_css("a")

    assert_equal "/themes/new##{Components::Editor::GenerationPanel::PROMPT_ID}", link["href"]
    assert_equal "false", link["data-turbo"]
    assert_equal "Describe a theme", link.text.strip
  end
end
