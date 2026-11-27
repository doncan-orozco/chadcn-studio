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
    assert_empty sidebars_outside_their_card
  end

  test "the gallery index and the header links are not covered by the page content" do
    visit gallery_path

    assert_selector "nav[aria-label='Components'] a", minimum: 1
    coverage = links_covered_by_content

    assert_empty coverage["covered"]
    assert_operator coverage["reachable"], :>=, 1, "no index link could be hit-tested in the first viewport"
  end

  test "the index marks the entry in view as current and follows the scroll" do
    visit gallery_path

    assert_selector "nav[aria-label='Components'] a[aria-current='location']", count: 1, visible: :all
    initial_entry_id = find("nav[aria-label='Components'] a[aria-current='location']", visible: :all)[:href].split("#").last

    assert_not_equal initial_entry_id, last_entry_id
    page.execute_script("document.getElementById(arguments[0]).scrollIntoView()", last_entry_id)

    assert_selector "nav[aria-label='Components'] a[aria-current='location'][href='##{last_entry_id}']", count: 1, visible: :all
    assert_selector "nav[aria-label='Components'] a[aria-current='location']", count: 1, visible: :all
  end

  test "the current marker is more than color: the current link is heavier than the others" do
    visit gallery_path

    weights = evaluate_script(<<~JS)
      (() => {
        const links = [...document.querySelectorAll("nav[aria-label='Components'] a")]
        const current = links.find((link) => link.getAttribute("aria-current") === "location")
        const other = links.find((link) => link !== current)
        return [current, other].map((link) => parseInt(getComputedStyle(link).fontWeight, 10))
      })()
    JS

    assert_operator weights.first, :>, weights.last
  end

  test "typing in the index filter narrows the links and hides a letter with none left" do
    visit gallery_path
    total = all("nav[aria-label='Components'] li", visible: :all).size
    fill_in "Find a component", with: "accordion"

    assert_selector "nav[aria-label='Components'] li:not([hidden]) a", text: "Accordion", visible: :all
    assert_operator all("nav[aria-label='Components'] li:not([hidden])", visible: :all).size, :<, total
    assert_equal 1, all("nav[aria-label='Components'] section:not([hidden])", visible: :all).size
  end

  test "a filter that matches nothing says so and clearing it restores the index" do
    visit gallery_path
    fill_in "Find a component", with: "zzzzzz"

    assert_text "No component matches"
    assert_no_selector "nav[aria-label='Components'] li:not([hidden])", visible: :all
    fill_in "Find a component", with: ""

    assert_no_text "No component matches"
    assert_selector "nav[aria-label='Components'] li:not([hidden])", minimum: 2, visible: :all
  end

  private

  def last_entry_id
    @last_entry_id ||= all(:testid, "gallery-entry", visible: :all).last[:id]
  end

  def sidebars_outside_their_card
    evaluate_script(<<~JS)
      [...document.querySelectorAll("[data-slot='sidebar-container']")].filter((sidebar) => {
        const card = sidebar.closest("[data-testid='gallery-card']").getBoundingClientRect()
        const box = sidebar.getBoundingClientRect()
        return box.left < card.left - 1 || box.right > card.right + 1 || box.top < card.top - 1 || box.bottom > card.bottom + 1
      }).map((sidebar) => JSON.stringify(sidebar.getBoundingClientRect()))
    JS
  end

  # Links fully inside the first viewport (and inside their own scroll container: the index scrolls), split into the ones the
  # user can hit and the ones something else covers.
  def links_covered_by_content
    evaluate_script(<<~JS)
      (() => {
        const coverage = { reachable: 0, covered: [] }
        document.querySelectorAll("nav a, header a").forEach((link) => {
          const box = link.getBoundingClientRect()
          if (box.width === 0 || box.height === 0 || box.top < 0 || box.bottom > window.innerHeight) return
          const scroller = link.closest("nav")
          const bounds = scroller ? scroller.getBoundingClientRect() : null
          if (bounds && (box.bottom > bounds.bottom || box.top < bounds.top)) return
          const hit = document.elementFromPoint(box.left + box.width / 2, box.top + box.height / 2)
          if (hit && (link.contains(hit) || hit.contains(link))) coverage.reachable++
          else coverage.covered.push(link.textContent.trim())
        })
        return coverage
      })()
    JS
  end
end
