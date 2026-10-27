# frozen_string_literal: true

# The one HTML document of the app. Pages render inside `Components::Shell::Frame`; a page fills the sidebar slot with
# `content_for(:sidebar) { ... }` and the page title with `content_for(:title)`.
class Views::Layouts::Application < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::Flash

  # Layouts are request-bound by nature (CSRF, CSP, flash): this is the one view that reads the view context.
  def view_template
    doctype
    html(lang: "en") do
      head do
        title { content_for(:title).presence || "Chadcn Studio" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        csrf_meta_tags
        csp_meta_tag
        raw safe(content_for(:head).to_s)
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag :app, data_turbo_track: "reload"
        javascript_importmap_tags
      end

      body(class: "bg-background text-foreground antialiased") do
        render Components::Shell::Frame.new(sidebar: content_for(:sidebar).presence) { yield }
        render Chadcn::Toaster.new(flash: flash.to_h, close_button: true)
      end
    end
  end
end
