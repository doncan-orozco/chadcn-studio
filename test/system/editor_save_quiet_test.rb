require "test_helper"
require "application_system_test_case"

class EditorSaveQuietTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "Save is quiet while the editor matches the stored theme and loud after an edit" do
    assert_selector(:button, "Save theme") { |save| save[:"data-quiet"] }
    quiet = save_background

    assert_not_equal token_background("bg-primary"), quiet

    fill_in "Name", with: "Renamed"

    assert_selector(:button, "Save theme") { |save| save[:"data-quiet"].nil? }
    assert_selector :testid, "unsaved"
    assert_not_equal quiet, save_background
  end

  test "Export is the one primary while saved and hands it to Save at the first edit" do
    primary = token_background("bg-primary")

    assert_selector(:button, "Export") { |export| export[:"data-dirty"].nil? && background_of(export) == primary }
    assert_not_equal primary, background("Save theme")

    fill_in "Name", with: "Renamed"

    # Colours transition, so each side is awaited rather than read once.
    assert_selector(:button, "Export") { |export| export[:"data-dirty"] && background_of(export) != primary }
    assert_selector(:button, "Save theme") { |save| background_of(save) == primary }
  end

  test "a rejected Save leaves Export outline, so Save stays the one primary" do
    execute_script("const name = document.getElementById('theme-name'); name.removeAttribute('required'); name.value = ''")
    click_on "Save theme"

    assert_selector :testid, "unsaved", text: "Unsaved changes"
    primary = token_background("bg-primary")
    assert_selector(:button, "Export") { |export| export[:"data-dirty"] && background_of(export) != primary }
  end

  test "publishing from the Export dialog while dirty brings Export back outline" do
    fill_in "Name", with: "Renamed"
    click_on "Export"
    click_on "Publish and show import command"

    assert_selector :testid, "export-panel"
    find("body").send_keys(:escape)
    primary = token_background("bg-primary")
    assert_selector(:button, "Export") { |export| export[:"data-dirty"] && background_of(export) != primary }
  end

  test "a rejected Save comes back with the default Save" do
    # Blank the name without an input event: only the server's rejection can drop data-quiet and show Unsaved changes.
    execute_script("const name = document.getElementById('theme-name'); name.removeAttribute('required'); name.value = ''")

    assert_selector(:button, "Save theme") { |save| save[:"data-quiet"] }
    assert_no_selector :testid, "unsaved"

    click_on "Save theme"

    assert_selector :testid, "unsaved", text: "Unsaved changes"
    assert_selector(:button, "Save theme", disabled: :all) { |save| save[:"data-quiet"].nil? }
  end

  private

  def save_background = background("Save theme")

  def background_of(button) = button.evaluate_script("getComputedStyle(this).backgroundColor")

  def background(label) = find_button(label).evaluate_script("getComputedStyle(this).backgroundColor")

  # The computed colour of a semantic token, read from a probe so the test never hard-codes a colour.
  def token_background(utility)
    evaluate_script(<<~JS)
      (() => { const probe = document.createElement("span"); probe.className = "#{utility}"; document.body.append(probe)
               const color = getComputedStyle(probe).backgroundColor; probe.remove(); return color })()
    JS
  end
end
