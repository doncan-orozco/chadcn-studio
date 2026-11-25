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
    div(class: "grid gap-4") do
      div(class: "flex gap-2") do
        render Chadcn::Button.new(as_child: :a, href: @presenter.css.path, download: @presenter.css.filename, data: { testid: "download-css" }) { "Download CSS" }
        render Chadcn::Button.new(as_child: :a, href: @presenter.json.path, download: @presenter.json.filename, variant: "outline", data: { testid: "download-json" }) { "Download JSON" }
      end
      div(class: "grid gap-1") do
        render Chadcn::Label.new(html_for: "import-command") { "Import into a chadcn app" }
        render Chadcn::Input.new(id: "import-command", readonly: true, value: @presenter.css.import_command, class: "font-mono text-xs", data: { testid: "import-command" })
      end
    end
  end
end
