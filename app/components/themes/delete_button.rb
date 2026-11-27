# frozen_string_literal: true

class Components::Themes::DeleteButton < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  # Outline look in the destructive color; the dark: classes beat the outline variant's dark:border-input.
  DESTRUCTIVE_OUTLINE = "text-destructive hover:text-destructive border-destructive/50 dark:border-destructive/50 hover:bg-destructive/10 dark:hover:bg-destructive/20"

  VARIABLE_COUNT = (Chadcn::Theme::REQUIRED + Chadcn::Theme::ROOT_ONLY).size

  # label names the theme ("Delete Sunset"): it is the trigger's accessible name, the dialog title and the confirm.
  def initialize(theme_id:, label:, size: "default", **attrs)
    @theme_id = theme_id
    @label = label
    @size = size
    @attrs = attrs
  end

  def view_template
    # Hidden: it is submitted by id from the portaled confirm, and must not become a flex item beside the trigger.
    form(id: form_id, action: theme_path(@theme_id), method: "post", hidden: true) do
      input(type: "hidden", name: "_method", value: "delete")
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
    end
    render Chadcn::AlertDialog.new(id: dialog_id) do
      render Chadcn::AlertDialog::Trigger.new(as_child: trigger_button) { "Delete" }
      render Chadcn::AlertDialog::Content.new { confirmation }
    end
  end

  private

  def form_id = "delete-theme-#{@theme_id}-form"

  def dialog_id = "delete-theme-#{@theme_id}-dialog"

  def trigger_button = Chadcn::Button.new(variant: "outline", size: @size, aria: { label: @label }, **button_attrs)

  # The confirm lives in the portaled content, outside the form, so it submits it by id. It is a plain submit button, not
  # AlertDialog::Action: Action closes (and may unmount) the content inside the click, before the browser submits. The
  # redirect closes the dialog, and Turbo disables the button while the DELETE is in flight.
  def confirmation
    render Chadcn::AlertDialog::Header.new do
      render(Chadcn::AlertDialog::Title.new { "#{@label}?" })
      render(Chadcn::AlertDialog::Description.new { "Its #{VARIABLE_COUNT} variables will be lost. This cannot be undone." })
    end
    render Chadcn::AlertDialog::Footer.new do
      render(Chadcn::AlertDialog::Cancel.new { "Cancel" })
      render(Chadcn::Button.new(variant: "destructive", type: "submit", form: form_id, data: { testid: "confirm-delete" }) { @label })
    end
  end

  # Every attribute the caller passes reaches the button; the destructive look is prepended to its class.
  def button_attrs = @attrs.merge(class: [ DESTRUCTIVE_OUTLINE, @attrs[:class] ].compact.join(" "))
end
