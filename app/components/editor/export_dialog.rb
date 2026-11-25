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
