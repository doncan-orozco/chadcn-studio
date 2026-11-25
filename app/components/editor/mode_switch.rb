# frozen_string_literal: true

# Previews the dark palette: the gem's switch tells the preview controller, which toggles `.dark` on the preview root only.
class Components::Editor::ModeSwitch < Components::Base
  def view_template
    div(class: "flex min-h-6 w-full items-center gap-3") do
      render Chadcn::Switch.new(id: "preview-dark", data: { action: "chadcn--switch:checked-change->editor--preview#mode", testid: "preview-dark" })
      render Chadcn::Label.new(html_for: "preview-dark", class: "flex-1 min-h-6") { "Preview in dark mode" }
    end
  end
end
