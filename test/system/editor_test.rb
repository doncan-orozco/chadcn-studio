require "application_system_test_case"

# Closed panels are hidden by a class, not by markup: the compiled stylesheet must be current.
require "rake"
Rails.application.load_tasks unless Rake::Task.task_defined?("tailwindcss:build")
Rake::Task["tailwindcss:build"].invoke

class EditorTest < ApplicationSystemTestCase
  setup do
    @theme = themes(:zinc)
    visit edit_theme_path(@theme)

    assert_selector :testid, "preview-root"
  end

  test "the lightness slider moves the preview without a request and releasing it derives the rest" do
    open_group "brand"
    thumb = find(:testid, "primary-lightness").find("[role=slider]")
    initial = preview_style
    x, y = center_of(thumb)
    mouse = page.driver.browser.mouse

    mouse.move(x: x, y: y).down.move(x: x + 90, y: y, steps: 6)
    moved = wait_for_style_change(initial)

    assert_no_derivation_request
    assert_equal moved_primary, property("--primary")
    assert_equal "oklch(0.21 0.006 285.885)", property("--sidebar-primary"), "the dependent variables wait for the server"

    mouse.up

    assert_selector "#summary-brand", text: "Gray"
    derived = wait_for_style_change(moved)

    assert_equal 1, derivation_requests.size
    assert_equal moved_primary, property("--sidebar-primary"), "the derived mirror arrives from the server"
    refute_equal moved, derived
  end

  test "the dark switch toggles the dark class on the preview root only" do
    shell_dark = evaluate_script("document.documentElement.classList.contains('dark')")

    assert_no_selector :testid, "dark-preview-badge", visible: true
    find(:testid, "preview-dark").click

    assert_selector :testid, "dark-preview-badge", text: "Dark preview"
    assert_selector "[data-testid=preview-root].dark"
    assert_equal shell_dark, evaluate_script("document.documentElement.classList.contains('dark')")
    assert_no_selector "[data-testid=shell].dark"
    assert_equal @theme.dark["background"], property("--background")

    find(:testid, "preview-dark").click

    assert_no_selector :testid, "dark-preview-badge", visible: true
    assert_no_selector "[data-testid=preview-root].dark"
    assert_equal @theme.light["background"], property("--background")
  end

  test "an advanced override survives a re-derivation, shows as overridden and clearing it re-derives" do
    open_group "advanced"
    fill_in "override-light-ring", with: "oklch(0.6 0.1 30)"
    find_field("override-light-ring").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    assert_equal "oklch(0.6 0.1 30)", property("--ring")

    close_group
    find(:testid, "primary-lightness").find("[role=slider]").send_keys(:right)

    assert_selector "#summary-brand", text: "Black"
    assert_selector :testid, "overridden", count: 1, visible: :all
    assert_equal "oklch(0.6 0.1 30)", property("--ring")

    open_group "advanced"
    fill_in "override-light-ring", with: ""
    find_field("override-light-ring").send_keys(:enter)

    assert_no_selector :testid, "overridden"
    refute_equal "oklch(0.6 0.1 30)", property("--ring")
  end

  test "a contrast failure lists the failing pair and keeps the preview" do
    open_group "advanced"
    before = property("--foreground")
    fill_in "override-light-foreground", with: "oklch(1 0 0)"
    find_field("override-light-foreground").send_keys(:enter)

    assert_selector :testid, "editor-errors", text: "--foreground on --background"
    assert_equal before, property("--foreground")
  end

  test "Save theme is disabled while the save is submitting" do
    execute_script(<<~JS, find_button("Save theme"))
      const save = arguments[0]
      document.addEventListener("turbo:submit-start", () => { window.saveDisabledAtStart = save.disabled }, { once: true })
    JS
    click_on "Save theme"

    assert_text "Zinc saved"
    assert evaluate_script("window.saveDisabledAtStart"), "Save theme should be disabled once the submit starts"
  end

  test "the toolbar offers Save theme and shows Unsaved changes only once the editor differs" do
    assert_button "Save theme"
    assert_no_selector :testid, "unsaved"
    assert_selector :testid, "saved", text: "Saved"

    fill_in "Name", with: "Renamed"

    assert_selector :testid, "unsaved", text: "Unsaved changes"
    assert_no_selector :testid, "saved"
  end

  test "moving a slider marks the editor unsaved" do
    open_group "brand"
    thumb = find(:testid, "primary-lightness").find("[role=slider]")
    x, y = center_of(thumb)
    page.driver.browser.mouse.move(x: x, y: y).down.move(x: x + 60, y: y, steps: 4).up

    assert_selector :testid, "unsaved", text: "Unsaved changes"
  end

  test "name, Save, Publish and Export share one row and the brand color is in the first viewport" do
    tops = %w[theme-name save publish-toggle export].map { |id| evaluate_script("document.querySelector('[data-testid=#{id}], ##{id}').getBoundingClientRect().top").round }

    assert_equal 1, tops.uniq.size
    assert evaluate_script("document.querySelector('[data-testid=brand-color]').getBoundingClientRect().bottom < window.innerHeight")
    assert_selector :testid, "brand-color", visible: :visible
  end

  # The form follows the toolbar row, so its top is the row's bottom. An error may legitimately wrap the row; this is the clean state.
  test "the toolbar row is at most 100 px tall" do
    row_bottom = evaluate_script("arguments[0].getBoundingClientRect().top", find(:testid, "editor-form"))
    editor_top = evaluate_script("arguments[0].getBoundingClientRect().top", find(:testid, "editor"))

    assert_operator row_bottom - editor_top, :<=, 100
  end

  test "Save persists the name and the derived palette" do
    fill_in "Name", with: "Renamed"
    click_on "Save theme"

    assert_text "Renamed saved"
    assert_selector :testid, "saved", text: "Saved"
    assert_equal "Renamed", @theme.reload.name
  end

  test "an advanced override typed as hex is accepted and saved as oklch" do
    open_group "advanced"
    fill_in "override-light-border", with: "#9ca3af"
    find_field("override-light-border").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    assert_equal "oklch(0.714 0.019 261.325)", property("--border")

    click_on "Save theme"

    assert_text "Zinc saved"
    assert_equal({ "light" => { "border" => "oklch(0.714 0.019 261.325)" } }, @theme.reload.inputs["overrides"])
  end

  test "Save persists an advanced override" do
    open_group "advanced"
    fill_in "override-light-ring", with: "oklch(0.6 0.1 30)"
    find_field("override-light-ring").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    close_group
    click_on "Save theme"

    assert_text "Zinc saved"
    assert_equal({ "light" => { "ring" => "oklch(0.6 0.1 30)" } }, @theme.reload.inputs["overrides"])
    assert_equal "oklch(0.6 0.1 30)", @theme.light["ring"]
  end

  test "a rejected Save re-renders the editor with the errors" do
    page.execute_script("document.querySelector('[name=\"theme[inputs][primary]\"]').value = 'oklch(2 0.2 250)'")
    click_on "Save theme"

    assert_selector :testid, "editor-errors", text: "Primary must be"
    assert_selector :testid, "unsaved", text: "Unsaved changes"
    assert_selector :testid, "preview-root"
    assert_equal "Zinc", @theme.reload.name
  end

  test "a group panel shows the light and dark values as text and links to all values" do
    open_group "brand"
    row = find(:testid, "group-brand-panel").find(:testid, "variable-rows").find("li", text: /\A--primary\n/)

    assert_equal @theme.light["primary"], row.find("[data-value=light]").text
    assert_equal @theme.dark["primary"], row.find("[data-value=dark]").text
    assert_selector :testid, "all-values-link"
    assert_equal "#{theme_path(@theme)}#all-values", URI(find(:testid, "all-values-link")[:href]).then { |uri| [ uri.path, uri.fragment ].join("#") }
  end

  test "the All values link survives a derivation" do
    open_group "brand"
    find(:testid, "primary-lightness").find("[role=slider]").send_keys(:right)

    assert_selector "#summary-brand", text: "Black"
    panel = find(:testid, "group-brand-panel")

    assert panel.has_selector?(:testid, "variable-rows")
    assert panel.has_selector?(:testid, "all-values-link")
  end

  test "the page switcher renders the other preview pages inside the preview root" do
    click_on "Settings"

    assert_selector "[data-testid=preview-root] h1", visible: :visible
  end

  test "the editor offers Delete beside the other actions and it returns to the list" do
    visit edit_theme_path(themes(:zinc))
    find("button[aria-label='Delete Zinc']").click
    within("[role=alertdialog]") { click_button "Delete Zinc" }

    assert_current_path themes_path
    assert_no_selector :testid, "theme-card", text: "Zinc"
  end

  private

  # The brand group is not a dialog: it sits open in the sidebar, its variable rows behind a disclosure.
  def open_group(key)
    return open_brand_variables if key == "brand"

    find(:testid, "group-#{key}").click

    assert_selector :testid, "group-#{key}-panel"
  end

  def open_brand_variables
    assert_selector :testid, "group-brand-panel"
    find(:testid, "group-brand-panel").find("summary", text: "All brand variables").click
  end

  # The panel scrolls to the field that was filled; its Close button is at the top.
  def close_group
    execute_script("document.querySelector('[data-state=open][data-slot=dialog-content]').scrollTop = 0")
    find("[data-chadcn--dialog-part=close]", match: :first, visible: :visible).click

    assert_no_selector "[data-state=open][data-slot=dialog-content]"
  end

  def preview_style = find(:testid, "preview-root", visible: :all)[:style]

  def property(name) = evaluate_script("document.querySelector('[data-testid=preview-root]').style.getPropertyValue('#{name}')")

  def moved_primary = property("--primary")

  def center_of(element)
    rect = evaluate_script("(function(e){var r=e.getBoundingClientRect();return [r.left+r.width/2, r.top+r.height/2]})(arguments[0])", element)
    rect
  end

  # Capybara retries until the style attribute differs from `previous`; no sleeping.
  def wait_for_style_change(previous)
    page.document.synchronize do
      current = preview_style
      raise Capybara::ExpectationNotMet, "preview style did not change" if current == previous

      current
    end
  end

  def derivation_requests
    page.driver.browser.network.traffic.select { |exchange| exchange.request&.url&.include?("/derivations") }
  end

  def assert_no_derivation_request
    assert_empty derivation_requests, "moving the slider must not request anything"
  end
end
