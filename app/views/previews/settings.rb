# frozen_string_literal: true

class Views::Previews::Settings < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto flex max-w-4xl flex-col gap-6 p-6 md:flex-row") do
      nav(aria: { label: "Settings" }, class: "flex gap-1 md:w-48 md:flex-col") do
        @presenter.sections.each do |key, label|
          active = key == @presenter.active_section
          a(href: root_path, aria: { current: (active ? "page" : nil) },
            class: "rounded-md px-3 py-2 text-sm hover:bg-accent hover:text-accent-foreground #{active ? 'bg-accent text-accent-foreground' : 'text-muted-foreground'}") { label }
        end
      end
      div(class: "min-w-0 flex-1 space-y-6") do
        profile
        notifications
      end
    end
  end

  private

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
        @presenter.notifications.each do |key, label, enabled|
          div(class: "flex items-center justify-between") do
            render Chadcn::Label.new(html_for: "notify-#{key}") { label }
            render Chadcn::Switch.new(id: "notify-#{key}", default_checked: enabled)
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
