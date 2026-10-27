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
end
