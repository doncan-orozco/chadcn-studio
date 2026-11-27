require "test_helper"
require "application_system_test_case"

class EditorSlidersTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "the brand sliders are named and say their value in their own unit" do
    lightness = find(:testid, "primary-lightness").find("[role=slider]")
    chroma = find(:testid, "primary-chroma").find("[role=slider]")

    assert_equal "Lightness", lightness["aria-label"]
    assert_equal "#{spoken(lightness["aria-valuenow"].to_f * 100, 1)}%", lightness["aria-valuetext"]
    assert_equal spoken(chroma["aria-valuenow"].to_f, 3).to_s, chroma["aria-valuetext"]
    assert_match(/\A\d+°\z/, find(:testid, "primary-hue").find("[role=slider]")["aria-valuetext"])
  end

  test "the spoken value follows the slider" do
    thumb = find(:testid, "primary-lightness").find("[role=slider]")
    before = thumb["aria-valuetext"]
    thumb.execute_script("this.focus()")
    2.times { page.driver.browser.keyboard.type(:Right) }

    assert_no_selector "[data-testid=primary-lightness] [role=slider][aria-valuetext='#{before}']"
  end

  test "the Surfaces popover holds its slider and its values inside its box" do
    find(:testid, "group-surfaces").click

    assert_selector :testid, "group-surfaces-panel"
    overflowing = page.evaluate_script(<<~JS)
      (() => {
        const panel = document.querySelector("[data-testid=group-surfaces-panel]")
        const box = panel.getBoundingClientRect()
        const outside = [...panel.querySelectorAll("*")].filter((el) => {
          const r = el.getBoundingClientRect()
          return r.width > 0 && (r.right > box.right + 1 || r.left < box.left - 1)
        })
        return outside.length + Math.max(0, panel.scrollWidth - panel.clientWidth)
      })()
    JS

    assert_equal 0, overflowing
  end

  private

  # Mirrors Number(x.toFixed(d)) in slider_speech_controller.js: 21.0 is "21", 48.8 is "48.8".
  def spoken(value, digits)
    rounded = value.round(digits)
    rounded == rounded.to_i ? rounded.to_i : rounded
  end
end
