# frozen_string_literal: true

# The part of the dialog that depends on publication: the publish button on a draft, the links and command once public.
class Components::Editor::ExportDialog::Body < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  ORIGIN = "export_dialog"
  # The publish form says which trigger its dialog came from (`trigger=row`), so the response rebuilds that very trigger.
  TRIGGER_ROW = "row"

  def initialize(presenter:, compact: false)
    @presenter = presenter
    @compact = compact
  end

  def view_template
    div { @presenter.published? ? download_links : draft_offer }
  end

  private

  def draft_offer
    form(action: @presenter.publication_path, method: "post", class: "grid gap-3", data: { testid: "export-draft" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "from", value: ORIGIN)
      input(type: "hidden", name: "trigger", value: TRIGGER_ROW) if @compact
      p(class: "text-sm text-muted-foreground") { "This theme is a draft. Publish it to get its download links and import command." }
      render Chadcn::Button.new(type: "submit", data: { testid: "export-publish" }) { "Publish and show import command" }
    end
  end

  def download_links
    div(class: "grid gap-4", data: { controller: "editor--export", editor__export_downloaded_label_value: @presenter.css.downloaded_label, editor__export_copied_label_value: "Copied" }) do
      div(class: "grid gap-2") do
        div(class: "flex gap-2") { download_buttons }
        span(class: "text-sm text-muted-foreground", role: "status", data: { testid: "download-css-status", editor__export_target: "downloadStatus" })
      end
      import_command
    end
  end

  def download_buttons
    render Chadcn::Button.new(as_child: :a, href: @presenter.css.path, download: @presenter.css.filename, data: { testid: "download-css", action: "editor--export#downloaded" }) { @presenter.css.download_label }
    render Chadcn::Button.new(as_child: :a, href: @presenter.json.path, download: @presenter.json.filename, variant: "outline", data: { testid: "download-json" }) { "Download JSON" }
  end

  def import_command
    div(class: "grid gap-1", role: "group", aria: { labelledby: "import-command-label" }) do
      p(id: "import-command-label", class: "text-sm font-medium leading-none") { "Import into a chadcn app" }
      code(class: "block w-full break-words rounded-md border bg-muted px-3 py-2 font-mono text-xs", data: { testid: "import-command", editor__export_target: "source" }) { with_wrap_points(@presenter.css.import_command) }
      div(class: "flex justify-end") do
        render Chadcn::Button.new(type: "button", variant: "outline", data: { testid: "import-copy", editor__export_target: "button", action: "editor--export#copy" }) { "Copy" }
      end
      span(class: "sr-only", role: "status", data: { testid: "import-copy-status", editor__export_target: "status" })
    end
  end

  # Emits the text with a wrap opportunity after "/" and ":" (not between the slashes of "://") and before "[".
  def with_wrap_points(text)
    text.split(%r{(?<=[/:])(?!/)|(?=\[)}).each do |token|
      plain token
      wbr
    end
  end
end
