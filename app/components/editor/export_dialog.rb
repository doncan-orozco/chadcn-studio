# frozen_string_literal: true

# Getting the theme out: download the CSS or JSON and read the command that imports the public URL. A draft has no URL
# yet, so the dialog offers to publish it in place; the publication answers with a Turbo Stream that swaps `Body` in.
class Components::Editor::ExportDialog < Components::Base
  def initialize(presenter:)
    @presenter = presenter
  end

  def view_template
    render Chadcn::Dialog.new(id: "export-dialog") do
      render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Button.new(variant: "outline", data: { testid: "export" })) { "Export" }
      render Chadcn::Dialog::Portal.new do
        render Chadcn::Dialog::Content.new(data: { testid: "export-panel" }) do
          heading
          render Body.new(presenter: @presenter)
        end
      end
    end
  end

  private

  def heading
    render Chadcn::Dialog::Header.new do
      render(Chadcn::Dialog::Title.new { @presenter.dialog_title })
      render(Chadcn::Dialog::Description.new { "A shadcn theme.css, or the same theme as JSON." })
    end
  end
end

# The part of the dialog that depends on publication: the publish button on a draft, the links and command once public.
class Components::Editor::ExportDialog::Body < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(presenter:)
    @presenter = presenter
  end

  def view_template
    div(id: "export-body") { @presenter.published? ? download_links : draft_offer }
  end

  private

  def draft_offer
    form(action: @presenter.publication_path, method: "post", class: "grid gap-3", data: { testid: "export-draft" }) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
      input(type: "hidden", name: "from", value: "export_dialog")
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
