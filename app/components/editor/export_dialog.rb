# frozen_string_literal: true

# Getting the theme out: download the CSS or JSON and copy the command that imports the public URL. A draft has no URL
# yet, so the dialog says to publish first.
class Components::Editor::ExportDialog < Components::Base
  def initialize(theme:)
    @theme = theme
  end

  def view_template
    render Chadcn::Dialog.new(id: "export-dialog") do
      render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Button.new(variant: "outline", data: { testid: "export" })) { "Export" }
      render Chadcn::Dialog::Portal.new do
        render Chadcn::Dialog::Content.new(data: { testid: "export-panel" }) do
          header
          @theme.published? ? published : draft
        end
      end
    end
  end

  private

  def header
    render Chadcn::Dialog::Header.new do
      render(Chadcn::Dialog::Title.new { "Export #{@theme.name}" })
      render(Chadcn::Dialog::Description.new { "A shadcn theme.css, or the same theme as JSON." })
    end
  end

  def draft
    p(class: "text-sm text-muted-foreground", data: { testid: "export-draft" }) { "Publish this theme to get its download links and import URL." }
  end

  def published
    css = Exports::Presenter::Css.new(@theme, url: theme_export_url(@theme.slug, format: "css"))
    div(class: "grid gap-4") do
      div(class: "flex gap-2") do
        render Chadcn::Button.new(as_child: :a, href: theme_export_path(@theme.slug, format: "css"), download: css.filename, data: { testid: "download-css" }) { "Download CSS" }
        render Chadcn::Button.new(as_child: :a, href: theme_export_path(@theme.slug, format: "json"), download: "#{@theme.slug}.json", variant: "outline", data: { testid: "download-json" }) { "Download JSON" }
      end
      div(class: "grid gap-1") do
        render Chadcn::Label.new(html_for: "import-command") { "Import into a chadcn app" }
        render Chadcn::Input.new(id: "import-command", readonly: true, value: css.import_command, class: "font-mono text-xs", data: { testid: "import-command" })
      end
    end
  end
end
