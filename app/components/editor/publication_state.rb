# frozen_string_literal: true

# The editor header's publication state: the Published or Not published badge and, once published, the public link.
# It has a stable id so a Turbo Stream can replace it when the theme is published from inside the Export dialog.
class Components::Editor::PublicationState < Components::Base
  ID = "publication-state-host"

  def initialize(presenter:)
    @presenter = presenter
  end

  def view_template
    span(id: ID, class: "flex items-center gap-2 text-sm") do
      render Chadcn::Badge.new(variant: @presenter.published? ? "default" : "secondary", data: { testid: "publication-state" }) { @presenter.publication_state }
      a(href: @presenter.public_path, class: "inline-block py-1 text-muted-foreground underline underline-offset-4", data: { testid: "publication-link" }) { @presenter.public_path } if @presenter.public_path
    end
  end
end
