# frozen_string_literal: true

# The theme editor: a toolbar form (name, save, the inputs the panels feed), the groups sidebar and the live preview.
# `editor--preview` wraps all three; only the preview root carries the palette.
class Views::Themes::Edit < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "flex flex-col", data: { controller: "editor--preview", action: "editor--color:picked->editor--preview#pick", testid: "editor" }) do
      render Views::Themes::Edit::Toolbar.new(@presenter)
      render Chadcn::Sidebar::Provider.new(class: "min-h-0 flex-col md:flex-row") do
        render Views::Themes::Edit::Groups.new(@presenter)
        render Views::Themes::Edit::Preview.new(@presenter)
      end
    end
  end
end
