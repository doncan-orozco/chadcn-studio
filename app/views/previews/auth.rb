# frozen_string_literal: true

class Views::Previews::Auth < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "grid gap-6 p-6 md:grid-cols-2") do
      sign_in
      sign_up
    end
  end

  private

  def sign_in
    render Chadcn::Card.new(class: "mx-auto w-full max-w-sm") do |card|
      card.header do
        card.title { "Sign in to #{@presenter.product}" }
        card.description { "Welcome back." }
      end
      card.content(class: "space-y-4") do
        render Chadcn::Alert.new(variant: "destructive") { |alert| alert.description { @presenter.sign_in_error } }
        email_field("signin")
        password_field("signin")
      end
      card.footer(class: "flex-col gap-2") do
        render Chadcn::Button.new(class: "w-full") { "Sign in" }
        render Chadcn::Button.new(variant: "outline", class: "w-full") { "Continue with GitHub" }
      end
    end
  end

  def sign_up
    render Chadcn::Card.new(class: "mx-auto w-full max-w-sm") do |card|
      card.header do
        card.title { "Create an account" }
        card.description { "Free for 14 days." }
      end
      card.content(class: "space-y-4") do
        render Chadcn::Field.new do |field|
          field.label(html_for: "signup-name") { "Name" }
          field.render Chadcn::Input.new(id: "signup-name")
        end
        email_field("signup")
        password_field("signup")
      end
      card.footer { render Chadcn::Button.new(class: "w-full") { "Create account" } }
    end
  end

  def email_field(prefix)
    render Chadcn::Field.new do |field|
      field.label(html_for: "#{prefix}-email") { "Email" }
      field.render Chadcn::Input.new(id: "#{prefix}-email", type: "email", placeholder: "you@example.com")
    end
  end

  def password_field(prefix)
    render Chadcn::Field.new do |field|
      field.label(html_for: "#{prefix}-password") { "Password" }
      field.render Chadcn::Input.new(id: "#{prefix}-password", type: "password")
    end
  end
end
