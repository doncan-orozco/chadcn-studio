require "test_helper"

class Components::Editor::BrandSlidersTest < ActiveSupport::TestCase
  test "renders the lightness, chroma and hue sliders of the primary color" do
    page = Capybara.string(Components::Editor::BrandSliders.new(group: Themes::Presenter::Group.new(themes(:zinc), key: "brand")).call)

    %w[primary-lightness primary-chroma primary-hue].each { |id| assert page.has_css?("[data-testid='#{id}']"), "missing #{id}" }
  end
end
