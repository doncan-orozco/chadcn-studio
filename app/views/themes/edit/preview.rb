# frozen_string_literal: true

# The page switcher (the preview pages as tabs) and the preview root they render inside.
class Views::Themes::Edit::Preview < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "min-w-0 flex-1 space-y-3 p-3") do
      div(id: "editor-palette") { render Components::Editor::PaletteSource.new(palette: @presenter.palette_json) }
      render Chadcn::Tabs.new(default_value: @presenter.first_page) do |tabs|
        tabs.list(aria: { label: "Preview page" }) do
          @presenter.pages.each { |page| tabs.trigger(value: page.key, data: { testid: "page-#{page.key}" }) { page.label } }
        end
        render Components::Editor::PreviewRoot.new(variables: @presenter.variables("light"), class: "rounded-lg border") do
          @presenter.pages.each { |page| tabs.content(value: page.key) { render page.view_class.new(page.presenter) } }
        end
      end
    end
  end
end
