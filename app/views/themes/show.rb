# frozen_string_literal: true

class Views::Themes::Show < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "mx-auto max-w-4xl space-y-6 p-6") do
      header(class: "flex items-center justify-between gap-4") do
        div do
          h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
          p(class: "text-muted-foreground") { @presenter.summary }
        end
        actions
      end
      render Views::Themes::Show::Palette.new(@presenter.rows)
    end
  end

  private

  def actions
    div(class: "flex items-center gap-2") do
      render Chadcn::Button.new(as_child: :a, href: themes_path, variant: "ghost") { "All themes" }
      render Chadcn::Button.new(as_child: :a, href: @presenter.edit_path, variant: "outline", aria: { label: @presenter.edit_label }) { "Edit" }
      render Components::Themes::DeleteButton.new(theme_id: @presenter.id, label: @presenter.delete_label)
    end
  end
end
