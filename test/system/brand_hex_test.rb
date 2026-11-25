require "application_system_test_case"

class BrandHexTest < ApplicationSystemTestCase
  setup do
    @theme = themes(:zinc)
    visit edit_theme_path(@theme)
  end

  test "typing a hex with or without # sets the brand color and the subtitle shows that hex" do
    fill_in "Hex", with: "0f766e"
    find_field("Hex").send_keys(:enter)

    assert_selector :testid, "brand-hex", text: "#0f766e"
    assert_field "Hex", with: "#0f766e"
    assert_selector :testid, "unsaved"
  end

  test "the hex typed survives Save and is shown back" do
    fill_in "Hex", with: "#0f766e"
    find_field("Hex").send_keys(:enter)

    assert_selector :testid, "brand-hex", text: "#0f766e"
    click_on "Save theme"

    assert_text "Zinc saved"
    assert_selector :testid, "brand-hex", text: "#0f766e"
    assert_equal "#0f766e", @theme.reload.inputs["primary_hex"]
  end

  test "something that is not a hex is refused where it was typed and changes nothing" do
    before = find(:testid, "brand-hex").text
    fill_in "Hex", with: "teal"
    find_field("Hex").send_keys(:enter)

    assert_selector :testid, "brand-hex-error", text: "Use a hex color"
    assert_equal "true", find_field("Hex")["aria-invalid"]
    assert_equal before, find(:testid, "brand-hex").text
  end

  test "the sidebar says changes show live and Save keeps them" do
    assert_selector :testid, "brand-live-note", text: "Changes show live; Save keeps them."
  end
end
