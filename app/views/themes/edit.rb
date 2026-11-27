# frozen_string_literal: true

# The theme editor: one toolbar row (title, name, Save, Publish, Export, Delete), the groups sidebar and the live preview.
# `editor--preview` wraps all three; only the preview root carries the palette.
class Views::Themes::Edit < Views::Base
  include Phlex::Rails::Helpers::ContentFor

  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    content_for(:title, @presenter.document_title)
    div(class: "flex flex-col", data: { controller: "editor--preview", action: "editor--color:picked->editor--preview#pick", testid: "editor" }) do
      render(Views::Themes::Edit::Toolbar.new(@presenter)) { sharing }
      render Chadcn::Sidebar::Provider.new(class: "min-h-0 flex-col md:flex-row") do
        render Views::Themes::Edit::Groups.new(@presenter)
        render Views::Themes::Edit::Preview.new(@presenter)
      end
    end
  end

  private

  def sharing
    sharing = Exports::Presenter::Sharing.new(@presenter, base_url: view_context.request.base_url)
    publication_state(sharing)
    render Components::Editor::PublishToggle.new(presenter: sharing)
    render Components::Editor::ExportDialog.new(presenter: sharing)
    render Components::Themes::DeleteButton.new(theme_id: @presenter.id, label: "Delete #{@presenter.name}")
  end

  def publication_state(sharing)
    path = sharing.public_path
    span(class: "flex items-center gap-2 text-sm") do
      render Chadcn::Badge.new(variant: sharing.published? ? "default" : "secondary", data: { testid: "publication-state" }) { sharing.publication_state }
      a(href: path, class: "inline-block py-1 text-muted-foreground underline underline-offset-4", data: { testid: "publication-link" }) { path } if path
    end
  end
end
