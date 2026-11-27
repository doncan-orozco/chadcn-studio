require "test_helper"
require "application_system_test_case"

class EditorSlidersTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "the brand sliders are named and say their value in their own unit" do
    lightness = find(:testid, "primary-lightness").find("[role=slider]")

    assert_equal "Lightness", lightness["aria-label"]
    assert_equal "#{(lightness["aria-valuenow"].to_f * 100).round}%", lightness["aria-valuetext"]
    assert_match(/\A\d+(\.\d+)?\z/, find(:testid, "primary-chroma").find("[role=slider]")["aria-valuetext"])
    assert_match(/\A\d+°\z/, find(:testid, "primary-hue").find("[role=slider]")["aria-valuetext"])
  end

  test "the spoken value follows the slider" do
    thumb = find(:testid, "primary-lightness").find("[role=slider]")
    before = thumb["aria-valuetext"]
    thumb.execute_script("this.focus()")
    2.times { page.driver.browser.keyboard.type(:Right) }

    assert_no_selector "[data-testid=primary-lightness] [role=slider][aria-valuetext='#{before}']"
  end
end
