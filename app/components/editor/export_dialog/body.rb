# frozen_string_literal: true

# The body of the Export dialog: the downloads always (a draft's go through the studio's own `?draft=1` export), then the publish
# offer on a draft, or the Published state, the public URL's import command and Unpublish once public.
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
    div(class: "grid gap-4", data: { controller: "editor--export", editor__export_downloaded_label_value: @presenter.css.downloaded_label, editor__export_copied_label_value: "Copied" }) do
      published_row if @presenter.published?
      downloads
      @presenter.published? ? import_command : draft_offer
    end
  end

  private

  # A draft is downloaded right away; only the public URL and the import command wait for Publish.
  def draft_offer
    publication_form(class: "grid gap-3", data: { testid: "export-draft" }) do
      p(class: "text-sm text-muted-foreground") { "This theme is a draft. Publishing makes it readable by anyone with its link, and you can unpublish it at any time." }
      render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "export-publish" }) { "Publish and show import command" }
    end
  end

  def downloads
    div(class: "grid gap-2") do
      div(class: "flex gap-2") { download_buttons }
      span(class: "text-sm text-muted-foreground", role: "status", data: { testid: "download-css-status", editor__export_target: "downloadStatus" })
    end
  end

  # The state and the way back, beside the public URL: Unpublish answers with the dialog open on its draft body.
  def published_row
    div(class: "flex items-center justify-between gap-2") do
      render Chadcn::Badge.new(data: { testid: "dialog-published" }) { "Published" }
      publication_form(unpublish: true, data: { testid: "export-unpublish-form" }) do
        render Chadcn::Button.new(type: "submit", variant: "outline", data: { testid: "export-unpublish" }) { "Unpublish" }
      end
    end
  end

  # The form to the publication (POST to publish, DELETE to unpublish) that says it comes from this dialog, and from which trigger.
  def publication_form(unpublish: false, **, &)
    form(action: @presenter.publication_path, method: "post", **) do
      input(type: "hidden", name: "_method", value: "delete") if unpublish
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "from", value: ORIGIN)
      input(type: "hidden", name: "trigger", value: TRIGGER_ROW) if @compact
      yield
    end
  end

  def download_buttons
    render Chadcn::Button.new(as_child: :a, href: download_href(@presenter.css.path), download: @presenter.css.filename, data: { testid: "download-css", action: "editor--export#downloaded" }) { @presenter.css.download_label }
    render Chadcn::Button.new(as_child: :a, href: download_href(@presenter.json.path), download: @presenter.json.filename, variant: "outline", data: { testid: "download-json" }) { "Download JSON" }
  end

  # A draft has no public URL: its download asks the studio's export for it with `draft`.
  def download_href(path) = @presenter.published? ? path : "#{path}?draft=1"

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
