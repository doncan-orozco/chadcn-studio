require "test_helper"
require "application_system_test_case"

# Target sizes and names on the tune pages: every slider thumb, the switch, the dialog Close and the toast close measure at
# least 24 x 24 on their own box and are named for a screen reader.
class TargetSizeTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "the radius slider thumb reads its name and value" do
    find(:testid, "group-radius").click
    thumb = find(:testid, "radius").find("[role=slider]")

    assert_equal "Corner radius", thumb["aria-label"]
    assert_equal "0.625rem", thumb["aria-valuetext"]
  end

  test "the surfaces slider thumb reads its name" do
    find(:testid, "group-surfaces").click

    assert_equal "Neutral tint", find(:testid, "neutral-tint").find("[role=slider]")["aria-label"]
  end

  test "the brand slider thumbs are named" do
    names = %w[primary-lightness primary-chroma primary-hue].map { |id| find(:testid, id).find("[role=slider]")["aria-label"] }

    assert_equal %w[Lightness Chroma Hue], names
  end

  test "the toast close is named" do
    click_on "Save theme"

    assert_equal "Close toast", find("[data-close-button]", visible: :all)["aria-label"]
  end

  # The box the audit measures is the element's own, so an `::after` overlay does not count; the layout size is read, since
  # a panel opening or a toast sliding in still scales and its bounding rect with it.
  test "every small control measures at least 24 x 24 on its own box" do
    find(:testid, "group-radius").click

    assert_selector :testid, "group-radius-panel"
    controls = page.evaluate_script(<<~JS)
      [...document.querySelectorAll("[role=slider], [role=switch], [data-slot=dialog-close]:has(.sr-only)")]
        .filter((el) => el.checkVisibility())
        .map((el) => [el.getAttribute("aria-label") || el.textContent.trim(), el.offsetWidth, el.offsetHeight])
    JS

    assert_operator controls.size, :>=, 5, "the brand thumbs, the radius thumb, the switch and a Close are on screen"
    assert_empty controls.select { |_, width, height| width < 24 || height < 24 }
  end

  test "the toast close measures 24 x 24" do
    click_on "Save theme"
    close = find("[data-close-button]", visible: :all)

    assert_operator close.evaluate_script("this.offsetWidth"), :>=, 24
    assert_operator close.evaluate_script("this.offsetHeight"), :>=, 24
  end

  test "the slider disc meets the track end at the minimum and the maximum, as the 16 px thumb did" do
    find(:testid, "group-radius").click
    slider = find(:testid, "group-radius-panel").find("[role=slider]", match: :first)
    slider.send_keys(:home)

    assert_in_delta 8, disc_distance_from_track(slider, :start), 0.5
    slider.send_keys(:end)

    assert_in_delta 8, disc_distance_from_track(slider, :end), 0.5
  end

  test "a theme row link is a target of at least 24 x 24" do
    visit root_path
    link = find("ul[aria-label='Your themes'] li > a", match: :first)

    assert_operator link.evaluate_script("this.offsetHeight"), :>=, 24
    assert_operator link.evaluate_script("this.offsetWidth"), :>=, 24
  end

  private

  # How far the disc's centre is from the track's start (or end), in CSS px.
  def disc_distance_from_track(thumb, side)
    thumb.evaluate_script(<<~JS, side.to_s)
      (function (thumb, side) {
        var track = thumb.closest("[data-slot=slider]").querySelector("[data-slot=slider-track]").getBoundingClientRect();
        var box = thumb.getBoundingClientRect(), centre = box.left + box.width / 2;
        return side === "start" ? centre - track.left : track.right - centre;
      })(this, arguments[0])
    JS
  end
end
