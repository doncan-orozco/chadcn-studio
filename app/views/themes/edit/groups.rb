# frozen_string_literal: true

# The sidebar of groups; each entry opens its panel.
class Views::Themes::Edit::Groups < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    brand = @presenter.group("brand")
    render Chadcn::Sidebar.new(collapsible: "none", class: "w-full border-b md:w-72 md:border-b-0 md:border-r", aria: { label: "Theme groups" }, data: { testid: "groups" }) do |sidebar|
      sidebar.content do
        render Components::Editor::GroupDialog.new(group: brand)
        render Chadcn::Sidebar::Group.new do
          render(Chadcn::Sidebar::GroupLabel.new { "Theme groups" })
          render Chadcn::Sidebar::GroupContent.new do
            render Chadcn::Sidebar::Menu.new do
              @presenter.groups.reject { |group| group.equal?(brand) }.each { |group| render Components::Editor::GroupDialog.new(group: group) }
            end
          end
        end
        generation
      end
    end
  end

  private

  # "Describe a theme" lives under the groups, at the width of the sidebar. A studio that cannot generate shows nothing here:
  # someone tuning a theme has no use for the setup line (New theme says how to turn it on).
  def generation
    panel = Generations::Presenter::Panel.for(@presenter.__getobj__)
    return unless panel.configured?

    div(class: "border-t p-2 [&_form]:flex-col [&_form]:items-stretch [&_input]:w-full") do
      render Components::Editor::GenerationPanel.new(panel: panel)
    end
  end
end
