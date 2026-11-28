# frozen_string_literal: true

# Getting the theme out: download the CSS or JSON and read the command that imports the public URL. A draft has no URL
# yet, so the dialog offers to publish it in place. The gem mounts the portal from an inert template on every open, so
# the publication answers with a Turbo Stream that replaces this whole host with the dialog open on the published body.
class Components::Editor::ExportDialog < Components::Base
  # While the theme is saved, the editor's Export is the page's one primary (the default Button look). At the first edit the preview
  # controller sets `data-dirty` on it and Save takes the primary: this is a copy of `Chadcn::Button::VARIANTS["outline"]` behind
  # `data-[dirty]:`, dark mode included (Tailwind needs the literal classes).
  DIRTY = "data-[dirty]:border data-[dirty]:bg-background data-[dirty]:text-foreground data-[dirty]:shadow-xs " \
          "data-[dirty]:hover:bg-accent data-[dirty]:hover:text-accent-foreground " \
          "dark:data-[dirty]:border-input dark:data-[dirty]:bg-input/30 dark:data-[dirty]:hover:bg-input/50"
  private_constant :DIRTY

  # One host and one dialog per theme, so a list of themes can carry an Export dialog on every row.
  def self.host_id(theme_id) = "export-dialog-host-#{theme_id}"

  # compact: the small outline trigger of a theme row, named after the theme it exports ("Export Sunset").
  def initialize(presenter:, open: false, compact: false)
    @presenter = presenter
    @open = open
    @compact = compact
  end

  def view_template
    div(id: self.class.host_id(@presenter.id), class: "contents") { dialog }
  end

  private

  def dialog
    render Chadcn::Dialog.new(id: "export-dialog-#{@presenter.id}", default_open: @open) do
      render Chadcn::Dialog::Trigger.new(as_child: trigger) { "Export" }
      render Chadcn::Dialog::Portal.new do
        render Chadcn::Dialog::Content.new(close_class: Components::Editor::HitArea::CLOSE, data: { testid: "export-panel" }) do
          heading
          render Body.new(presenter: @presenter, compact: @compact)
        end
      end
    end
  end

  # The editor's trigger carries the default look (see DIRTY); a row's stays outline. The accessible name starts with the visible text (WCAG 2.5.3); the editor's lone trigger needs no more than "Export".
  def trigger
    return Chadcn::Button.new(class: DIRTY, data: { testid: "export", editor__preview_target: "export" }) unless @compact

    Chadcn::Button.new(variant: "outline", size: "sm", aria: { label: @presenter.dialog_title }, data: { testid: "export" })
  end

  def heading
    render Chadcn::Dialog::Header.new do
      render(Chadcn::Dialog::Title.new { @presenter.dialog_title })
      render(Chadcn::Dialog::Description.new { "A shadcn theme.css, or the same theme as JSON." })
    end
  end
end
