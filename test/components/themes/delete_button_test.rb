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

  test "the form is hidden so it adds no flex item beside the trigger" do
    assert render_button(label: "Delete Zinc").at_css("form[hidden]")
  end

  test "the dialog is titled with the label, names the variables and offers Cancel and a destructive confirm that submits the form" do
    page = render_button(label: "Delete Zinc")
    confirm = page.at_css("[data-testid=confirm-delete]")

    assert_equal "Delete Zinc?", page.at_css("[data-slot=alert-dialog-title]").text
    assert_equal "Its 32 variables will be lost. This cannot be undone.", page.at_css("[data-slot=alert-dialog-description]").text
    assert_equal "Cancel", page.at_css("[data-slot=alert-dialog-cancel]").text
    assert_equal "Delete Zinc", confirm.text
    assert_equal "submit", confirm["type"]
    assert_equal page.at_css("form")["id"], confirm["form"]
    assert_equal "destructive", confirm["data-variant"]
    assert_nil confirm["data-chadcn--dialog-part"], "the confirm must not close (and unmount) itself before it submits"
  end

  test "label is required" do
    assert_raises(ArgumentError) { Components::Themes::DeleteButton.new(theme_id: 1) }
  end

  private

  def render_button(label: "Delete Zinc", **options)
    html = ApplicationController.render(Components::Themes::DeleteButton.new(theme_id: themes(:zinc).id, label:, **options), layout: false)
    Nokogiri::HTML5.fragment(html)
  end
end
