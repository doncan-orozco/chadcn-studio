# frozen_string_literal: true

# The sidebar of groups; each entry opens its panel.
class Views::Themes::Edit::Groups < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    render Chadcn::Sidebar.new(collapsible: "none", class: "w-full border-b md:w-72 md:border-b-0 md:border-r", aria: { label: "Theme groups" }, data: { testid: "groups" }) do |sidebar|
      sidebar.content do
        render Chadcn::Sidebar::Group.new do
          render(Chadcn::Sidebar::GroupLabel.new { "Theme groups" })
          render Chadcn::Sidebar::GroupContent.new do
            render Chadcn::Sidebar::Menu.new do
              @presenter.groups.each { |group| render Components::Editor::GroupDialog.new(group: group) }
            end
          end
        end
      end
    end
  end
end
