# frozen_string_literal: true

class Views::Previews::Settings < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-4xl space-y-6 p-6") do
      h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
      div(class: "flex flex-col gap-6 md:flex-row") do
        sections_nav
        div(class: "min-w-0 flex-1 space-y-6") do
          profile
          notifications
        end
      end
    end
  end

  private

  def sections_nav
    nav(aria: { label: "Settings" }, class: "flex gap-1 md:w-48 md:flex-col") do
      @presenter.sections.each do |section|
        render Chadcn::Button.new(
          as_child: :a, variant: "ghost", href: preview_path("settings"),
          aria: { current: ("page" if section.active) },
          class: section.active ? "justify-start bg-accent text-accent-foreground" : "justify-start text-muted-foreground"
        ) { section.label }
      end
    end
  end

  def profile
    render Chadcn::Card.new do |card|
      card.header do
        card.title { "Profile" }
        card.description { "How you appear to others." }
      end
      card.content(class: "space-y-4") do
        render Chadcn::Field.new do |field|
          field.label(html_for: "settings-name") { "Display name" }
          field.render Chadcn::Input.new(id: "settings-name", default_value: @presenter.display_name)
        end
        render Chadcn::Field.new do |field|
          field.label(html_for: "settings-bio") { "Bio" }
          field.render Chadcn::Textarea.new(id: "settings-bio", default_value: @presenter.bio)
        end
      end
      card.footer(class: "justify-between") do
        delete_dialog
        render Chadcn::Button.new { "Save changes" }
      end
    end
  end

  def notifications
    render Chadcn::Card.new do |card|
      card.header { card.title { "Notifications" } }
      card.content(class: "space-y-4") do
        @presenter.notifications.each do |notification|
          render Chadcn::Field.new(orientation: "horizontal") do |field|
            field.label(html_for: "notify-#{notification.key}") { notification.label }
            field.render Chadcn::Switch.new(id: "notify-#{notification.key}", default_checked: notification.enabled)
          end
        end
      end
    end
  end

  def delete_dialog
    render Chadcn::Dialog.new do |dialog|
      dialog.trigger(as_child: Chadcn::Button.new(variant: "destructive")) { "Delete account" }
      dialog.content do
        dialog.header do
          dialog.title { "Delete your account?" }
          dialog.description { "This cannot be undone." }
        end
        dialog.footer { render Chadcn::Button.new(variant: "destructive") { "Yes, delete" } }
      end
    end
  end
end
