# frozen_string_literal: true

# The part of the dialog that depends on publication: the publish button on a draft, the links and command once public.
class Components::Editor::ExportDialog::Body < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  ORIGIN = "export_dialog"

  def initialize(presenter:)
    @presenter = presenter
  end

  def view_template
    div { @presenter.published? ? download_links : draft_offer }
  end

  private

  def draft_offer
    form(action: @presenter.publication_path, method: "post", class: "grid gap-3", data: { testid: "export-draft" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "from", value: ORIGIN)
      p(class: "text-sm text-muted-foreground") { "This theme is a draft. Publish it to get its download links and import command." }
      render Chadcn::Button.new(type: "submit", data: { testid: "export-publish" }) { "Publish and show import command" }
    end
  end

  def download_links
    div(class: "grid gap-4", data: { controller: "editor--export", editor__export_downloaded_label_value: "Downloaded #{@presenter.css.filename}", editor__export_copied_label_value: "Copied" }) do
      div(class: "grid gap-2") do
        div(class: "flex gap-2") { download_buttons }
        span(class: "text-sm text-muted-foreground", role: "status", data: { testid: "download-css-status", editor__export_target: "downloadStatus" })
      end
      import_command
    end
  end

  def download_buttons
    render Chadcn::Button.new(as_child: :a, href: @presenter.css.path, download: @presenter.css.filename, data: { testid: "download-css", action: "editor--export#downloaded" }) { "Download #{@presenter.css.filename}" }
    render Chadcn::Button.new(as_child: :a, href: @presenter.json.path, download: @presenter.json.filename, variant: "outline", data: { testid: "download-json" }) { "Download JSON" }
  end

  def import_command
    div(class: "grid gap-1", role: "group", aria: { labelledby: "import-command-label" }) do
      p(id: "import-command-label", class: "text-sm font-medium leading-none") { "Import into a chadcn app" }
      div(class: "flex items-start gap-2") do
        code(class: "flex-1 break-all rounded-md border bg-muted px-3 py-2 font-mono text-xs", data: { testid: "import-command", editor__export_target: "source" }) { @presenter.css.import_command }
        render Chadcn::Button.new(type: "button", variant: "outline", data: { testid: "import-copy", editor__export_target: "button", action: "editor--export#copy" }) { "Copy" }
      end
      span(class: "sr-only", role: "status", data: { testid: "import-copy-status", editor__export_target: "status" })
    end
  end
end
