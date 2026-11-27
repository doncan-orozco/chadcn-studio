require "test_helper"

class Components::Editor::BrandSlidersTest < ActiveSupport::TestCase
  test "renders the lightness, chroma and hue sliders of the primary color" do
    page = Capybara.string(Components::Editor::BrandSliders.new(group: Themes::Presenter::Group.new(themes(:zinc), key: "brand")).call)

    %w[primary-lightness primary-chroma primary-hue].each { |id| assert page.has_css?("[data-testid='#{id}']"), "missing #{id}" }
  end

  test "each slider is named and says its value in its own unit" do
    page = Capybara.string(Components::Editor::BrandSliders.new(group: Themes::Presenter::Group.new(themes(:zinc), key: "brand")).call)

    { "primary-lightness" => [ "Lightness", "100", "1", "%" ], "primary-chroma" => [ "Chroma", "1", "3", "" ], "primary-hue" => [ "Hue", "1", "0", "°" ] }.each do |id, (name, scale, digits, unit)|
      field = page.find("[data-testid='#{id}']").ancestor("[data-controller='editor--slider-speech']")

      assert field.has_css?("[role=slider][aria-label='#{name}']"), "#{id} has no name"
      assert_equal scale, field["data-editor--slider-speech-scale-value"], id
      assert_equal digits, field["data-editor--slider-speech-digits-value"], id
      assert_equal unit, field["data-editor--slider-speech-unit-value"].to_s, id
    end
  end
end
