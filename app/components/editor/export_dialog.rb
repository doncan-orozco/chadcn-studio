# frozen_string_literal: true

# Getting the theme out: download the CSS or JSON and read the command that imports the public URL. A draft has no URL
# yet, so the dialog offers to publish it in place. The gem mounts the portal from an inert template on every open, so
# the publication answers with a Turbo Stream that replaces this whole host with the dialog open on the published body.
class Components::Editor::ExportDialog < Components::Base
  HOST_ID = "export-dialog-host"

  def initialize(presenter:, open: false)
    @presenter = presenter
    @open = open
  end

  def view_template
    div(id: HOST_ID, class: "contents") { dialog }
  end

  private

  def dialog
    render Chadcn::Dialog.new(id: "export-dialog", default_open: @open) do
      render Chadcn::Dialog::Trigger.new(as_child: Chadcn::Button.new(variant: "outline", data: { testid: "export" })) { "Export" }
      render Chadcn::Dialog::Portal.new do
        render Chadcn::Dialog::Content.new(close_class: Components::Editor::HitArea::CLOSE, data: { testid: "export-panel" }) do
          heading
          render Body.new(presenter: @presenter)
        end
      end
    end
  end

  def heading
    render Chadcn::Dialog::Header.new do
      render(Chadcn::Dialog::Title.new { @presenter.dialog_title })
      render(Chadcn::Dialog::Description.new { "A shadcn theme.css, or the same theme as JSON." })
    end
  end
end
