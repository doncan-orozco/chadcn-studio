# frozen_string_literal: true

class Views::Previews::Form < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-xl space-y-6 p-6") do
      h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
      render Chadcn::Card.new do |card|
        card.header do
          card.title { "Create account" }
          card.description { "Tell us a little about you." }
        end
        card.content { fields }
        card.footer(class: "justify-between") do
          render Chadcn::Button.new(variant: "outline") { "Cancel" }
          render Chadcn::Button.new { "Save" }
        end
      end
      danger
    end
  end

  private

  def fields
    div(class: "space-y-5") do
      render Chadcn::Field.new do |field|
        field.label(html_for: "form-name") { "Name" }
        field.render Chadcn::Input.new(id: "form-name", placeholder: "Ada Lovelace")
      end
      render Chadcn::Field.new(data: { invalid: "true" }) do |field|
        field.label(html_for: "form-email") { "Email" }
        field.render Chadcn::Input.new(id: "form-email", type: "email", default_value: @presenter.email_value, aria: { invalid: "true", describedby: "form-email-error" })
        field.error(id: "form-email-error") { @presenter.email_error }
      end
      render Chadcn::Field.new do |field|
        field.label(html_for: "form-bio") { "Bio" }
        field.render Chadcn::Textarea.new(id: "form-bio", placeholder: "A few words")
        field.description { "Shown on your public profile." }
      end
      role
      plan
      render Chadcn::Field.new(orientation: "horizontal") do |field|
        field.render Chadcn::Checkbox.new(id: "form-terms", default_checked: true)
        field.label(html_for: "form-terms") { "Accept the terms" }
      end
      render Chadcn::Field.new(orientation: "horizontal") do |field|
        field.label(html_for: "form-news") { "Product news" }
        field.render Chadcn::Switch.new(id: "form-news", default_checked: true)
      end
      render Chadcn::Field.new do |field|
        field.label { "Volume" }
        field.render Chadcn::Slider.new(default_value: @presenter.volume, aria: { label: "Volume" })
      end
    end
  end

  def role
    render Chadcn::Field.new do |field|
      field.label(html_for: "form-role") { "Role" }
      field.render Chadcn::Select.new(name: "role", default_value: "designer") do |select|
        select.trigger(id: "form-role", class: "w-full") { select.value(placeholder: "Pick a role") }
        select.content do
          @presenter.roles.each { |role| select.item(value: role.value) { role.label } }
        end
      end
    end
  end

  def plan
    render Chadcn::Field.new do |field|
      field.label(id: "form-plan-label") { "Plan" }
      field.render Chadcn::RadioGroup.new(name: "plan", default_value: "pro", aria: { labelledby: "form-plan-label" }) do |group|
        @presenter.plans.each do |plan|
          div(class: "flex items-center gap-3") do
            group.item(value: plan.value, id: "plan-#{plan.value}")
            render Chadcn::Label.new(html_for: "plan-#{plan.value}") { plan.summary }
          end
        end
      end
    end
  end

  def danger
    render Chadcn::Alert.new(variant: "destructive") do |alert|
      alert.title { "Delete account" }
      alert.description do
        plain "This permanently removes your data. "
        render Chadcn::Button.new(variant: "destructive", size: "sm", class: "mt-3") { "Delete account" }
      end
    end
  end
end
