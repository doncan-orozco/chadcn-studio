require "test_helper"

class Components::Themes::DeleteButtonTest < ActiveSupport::TestCase
  test "renders a DELETE form with a CSRF token and a button named after the theme" do
    page = render_button(label: "Delete Zinc")

    assert page.at_css("form[action='/themes/#{themes(:zinc).id}'] input[name=_method][value=delete]")
    assert page.at_css("form input[name=authenticity_token]")
    assert_equal "Delete", page.at_css("button[aria-label='Delete Zinc']").text
  end

  test "the size and every attribute the caller passes reach the button, the class is merged" do
    button = render_button(size: "sm", class: "ml-2", data: { testid: "delete" }).at_css("button")

    assert_equal "sm", button["data-size"]
    assert_equal "delete", button["data-testid"]
    assert_includes button["class"].split, "ml-2"
    assert_includes button["class"].split, "text-destructive"
  end

  private

  def render_button(**options)
    html = ApplicationController.render(Components::Themes::DeleteButton.new(theme_id: themes(:zinc).id, **options), layout: false)
    Nokogiri::HTML5.fragment(html)
  end
end
