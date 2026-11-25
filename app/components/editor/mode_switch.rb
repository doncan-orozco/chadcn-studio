# frozen_string_literal: true

# Previews the dark palette of the theme: the gem's switch tells the preview controller, which toggles `.dark` on the preview
# root only. It sits on the preview tab strip and names itself "Dark preview" with a badge for as long as it is on, so it is
# never confused with the studio's own Light/Dark appearance in the header.
class Components::Editor::ModeSwitch < Components::Base
  def view_template
    div(class: "group/mode flex min-h-6 items-center gap-2", data: { testid: "preview-mode" }) do
      span(class: "text-sm text-muted-foreground") { "Light" }
      render Chadcn::Switch.new(id: "preview-dark", aria: { label: "Dark preview" }, data: { action: "chadcn--switch:checked-change->editor--preview#mode", testid: "preview-dark" })
      render Chadcn::Label.new(html_for: "preview-dark", class: "min-h-6") { "Dark" }
      render Chadcn::Badge.new(variant: "secondary", class: "hidden group-has-[[aria-checked=true]]/mode:inline-flex", data: { testid: "dark-preview-badge" }) { "Dark preview" }
    end
  end
end
