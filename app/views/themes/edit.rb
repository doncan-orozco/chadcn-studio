# frozen_string_literal: true

# The theme editor: a toolbar form (name, save, the inputs the panels feed), the groups sidebar and the live preview.
# `editor--preview` wraps all three; only the preview root carries the palette.
class Views::Themes::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    content_for(:title, @presenter.document_title)
    div(class: "flex flex-col", data: { controller: "editor--preview", action: "editor--color:picked->editor--preview#pick", testid: "editor" }) do
      header
      render Chadcn::Sidebar::Provider.new(class: "min-h-0 flex-col md:flex-row") do
        render Views::Themes::Edit::Groups.new(@presenter)
        render Views::Themes::Edit::Preview.new(@presenter)
      end
    end
  end

  private

  # One row above the groups: the heading, the name and Save (the toolbar form), Publish, Export and the describe dialog.
  def header
    div(class: "flex flex-wrap items-end border-b", data: { testid: "editor-header" }) do
      h1(class: "px-3 pb-3 text-2xl font-semibold leading-9 tracking-tight") { @presenter.title }
      render Views::Themes::Edit::Toolbar.new(@presenter)
      actions
    end
  end

  def actions
    sharing = Exports::Presenter::Sharing.new(@presenter, base_url: view_context.request.base_url)
    div(class: "flex items-center gap-2 px-3 pb-3") do
      publication_state(sharing)
      render Components::Editor::PublishToggle.new(presenter: sharing)
      render Components::Editor::ExportDialog.new(presenter: sharing)
      render Components::Editor::GenerationPanel.new(panel: Generations::Presenter::Panel.for(@presenter.__getobj__))
    end
  end

  def publication_state(sharing)
    path = sharing.public_path
    span(class: "flex items-center gap-2 text-sm") do
      render Chadcn::Badge.new(variant: sharing.published? ? "default" : "secondary", data: { testid: "publication-state" }) { sharing.publication_state }
      a(href: path, class: "text-muted-foreground underline underline-offset-4", data: { testid: "publication-link" }) { path } if path
    end
  end
end
