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

  test "the Sidebar demo stays inside its card and leaves the index and header links uncovered" do
    visit gallery_path

    assert_selector "[data-slot='sidebar-container']", visible: :all
    escaped = evaluate_script(<<~JS)
      [...document.querySelectorAll("[data-slot='sidebar-container']")].filter((sidebar) => {
        const card = sidebar.closest("[data-testid='gallery-entry'] > div:last-child").getBoundingClientRect()
        const box = sidebar.getBoundingClientRect()
        return box.left < card.left - 1 || box.right > card.right + 1 || box.top < card.top - 1 || box.bottom > card.bottom + 1
      }).length
    JS

    assert_equal 0, escaped

    links = evaluate_script(<<~JS)
      [...document.querySelectorAll("nav a, header a")].filter((link) => {
        const box = link.getBoundingClientRect()
        if (box.width === 0 || box.height === 0) return false
        const hit = document.elementFromPoint(box.left + box.width / 2, box.top + box.height / 2)
        return hit && !link.contains(hit) && !hit.contains(link)
      }).length
    JS

    assert_equal 0, links
  end
end
