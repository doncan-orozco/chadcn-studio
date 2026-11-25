require "application_system_test_case"

class GalleryTest < ApplicationSystemTestCase
  %w[light dark].each do |scheme|
    test "the gallery renders in #{scheme} without JS errors" do
      visit gallery_path
      click_on scheme.capitalize

      assert_selector "h1", text: "Components"
      assert_selector :testid, "gallery-entry", minimum: 1
      assert_selector(scheme == "dark" ? "html.dark" : "html:not(.dark)")
    end
  end

  test "the index and letter groups are named and the index links have focus parity" do
    visit gallery_path

    assert_selector "nav[aria-label='Components']", visible: :all
    assert_selector "section[aria-label^='Components starting with'] > h2", minimum: 1
    link = find("nav[aria-label='Components'] a", match: :first, visible: :all)

    assert_includes link[:class], "hover:bg-accent"
    assert_includes link[:class], "focus-visible:ring-[3px]"
  end

  test "the Sidebar demo stays inside its card" do
    visit gallery_path

    assert_selector "[data-slot='sidebar-container']", visible: :all
    assert_equal 0, sidebars_outside_their_card
  end

  test "the gallery index and the header links are not covered by the page content" do
    visit gallery_path

    assert_selector "nav[aria-label='Components'] a", minimum: 1
    hits = link_hits

    assert_empty hits["covered"]
    assert_operator hits["reachable"], :>=, 1, "no index link could be hit-tested in the first viewport"
  end

  private

  def sidebars_outside_their_card
    evaluate_script(<<~JS)
      [...document.querySelectorAll("[data-slot='sidebar-container']")].filter((sidebar) => {
        const card = sidebar.closest("[data-testid='gallery-card']").getBoundingClientRect()
        const box = sidebar.getBoundingClientRect()
        return box.left < card.left - 1 || box.right > card.right + 1 || box.top < card.top - 1 || box.bottom > card.bottom + 1
      }).length
    JS
  end

  # Links fully inside the first viewport (and inside their own scroll container: the index scrolls), split into the ones the
  # user can hit and the ones something else covers.
  def link_hits
    evaluate_script(<<~JS)
      (() => {
        const result = { reachable: 0, covered: [] }
        document.querySelectorAll("nav a, header a").forEach((link) => {
          const box = link.getBoundingClientRect()
          if (box.width === 0 || box.height === 0 || box.top < 0 || box.bottom > window.innerHeight) return
          const scroller = link.closest("nav")
          const bounds = scroller ? scroller.getBoundingClientRect() : null
          if (bounds && (box.bottom > bounds.bottom || box.top < bounds.top)) return
          const hit = document.elementFromPoint(box.left + box.width / 2, box.top + box.height / 2)
          if (hit && (link.contains(hit) || hit.contains(link))) result.reachable++
          else result.covered.push(link.textContent.trim())
        })
        return result
      })()
    JS
  end
end
