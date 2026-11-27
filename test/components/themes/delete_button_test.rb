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

  test "the dialog is titled with the label, says what is lost and offers Cancel and a destructive confirm that submits the form" do
    page = render_button(label: "Delete Zinc")
    form_id = page.at_css("form")["id"]
    action = page.at_css("[data-slot=alert-dialog-action]")

    assert_equal "Delete Zinc?", page.at_css("[data-slot=alert-dialog-title]").text
    assert_match(/Its \d+ variables will be lost\. This cannot be undone\./, page.at_css("[data-slot=alert-dialog-description]").text)
    assert_equal "Cancel", page.at_css("[data-slot=alert-dialog-cancel]").text
    assert_equal "Delete Zinc", action.text
    assert_equal "submit", action["type"]
    assert_equal form_id, action["form"]
    assert_equal "destructive", action["data-variant"]
  end

  private

  def render_button(**options)
    html = ApplicationController.render(Components::Themes::DeleteButton.new(theme_id: themes(:zinc).id, **options), layout: false)
    Nokogiri::HTML5.fragment(html)
  end
end
