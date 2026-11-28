# frozen_string_literal: true

# The one HTML document of the app. Pages render inside `Components::Shell::Frame`; a page fills the sidebar slot with
# `content_for(:sidebar) { ... }` and the page title with `content_for(:title)`.
class Views::Layouts::Application < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor
  include Phlex::Rails::Helpers::Flash

  # Flash keys the toaster shows; any other key (e.g. `deleted`) belongs to the page that renders it.
  TOASTED_FLASH = %w[notice alert].freeze
  # The toast's 20 px close button becomes a 24 px box on the element itself (WCAG 2.2 SC 2.5.8) and keeps its 20 px circle: a
  # 2 px transparent border clips the background, and the 1 px edge is an inset shadow on the painted circle. `!` beats the
  # toaster's own `[data-sonner-toast] [data-close-button]` size and border rules.
  TOAST_CLOSE = "size-6! border-2! border-transparent! bg-clip-padding! shadow-[inset_0_0_0_1px_var(--gray4)] " \
                "in-[[data-sonner-theme=dark]]:shadow-[inset_0_0_0_1px_var(--normal-border)]"
  private_constant :TOAST_CLOSE

  # Layouts are request-bound by nature (CSRF, CSP, flash): this is the one view that reads the view context.
  def view_template
    doctype
    html(lang: "en") do
      head do
        title { content_for(:title).presence || Core::Presenter::Base::APP_NAME }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        csrf_meta_tags
        csp_meta_tag
        head_content = content_for(:head)
        raw safe(head_content) if head_content.present? && head_content.html_safe?
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag :app, data_turbo_track: "reload"
        javascript_importmap_tags
      end

      body(class: "bg-background text-foreground antialiased") do
        render Components::Shell::Frame.new(sidebar: content_for(:sidebar).presence) { yield }
        render Chadcn::Toaster.new(flash: flash.to_h.slice(*TOASTED_FLASH), close_button: true, toast_options: { class_names: { close_button: TOAST_CLOSE } })
      end
    end
  end
end
