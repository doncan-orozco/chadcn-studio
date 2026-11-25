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

    assert_selector "#summary-brand", text: moved_primary
    derived = wait_for_style_change(moved)

    assert_equal 1, derivation_requests.size
    assert_equal moved_primary, property("--sidebar-primary"), "the derived mirror arrives from the server"
    refute_equal moved, derived
  end

  test "the dark switch toggles the dark class on the preview root only" do
    shell_dark = evaluate_script("document.documentElement.classList.contains('dark')")
    open_group "dark"
    find(:testid, "preview-dark").click

    assert_selector "[data-testid=preview-root].dark"
    assert_equal shell_dark, evaluate_script("document.documentElement.classList.contains('dark')")
    assert_no_selector "[data-testid=shell].dark"
    assert_equal @theme.dark["background"], property("--background")

    find(:testid, "preview-dark").click

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
    open_group "brand"
    find(:testid, "primary-lightness").find("[role=slider]").send_keys(:right)

    assert_selector "#summary-brand", text: "oklch(0.215"
    assert_selector :testid, "overridden", count: 1, visible: :all
    assert_equal "oklch(0.6 0.1 30)", property("--ring")

    close_group
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

  test "Save persists the name and the derived palette" do
    fill_in "Name", with: "Renamed"
    click_on "Save"

    assert_text "Theme saved"
    assert_equal "Renamed", @theme.reload.name
  end

  test "an advanced override typed as hex is accepted and saved as oklch" do
    open_group "advanced"
    fill_in "override-light-border", with: "#9ca3af"
    find_field("override-light-border").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    assert_equal "oklch(0.714 0.019 261.325)", property("--border")

    click_on "Save"

    assert_text "Theme saved"
    assert_equal({ "light" => { "border" => "oklch(0.714 0.019 261.325)" } }, @theme.reload.inputs["overrides"])
  end

  test "Save persists an advanced override" do
    open_group "advanced"
    fill_in "override-light-ring", with: "oklch(0.6 0.1 30)"
    find_field("override-light-ring").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    close_group
    click_on "Save"

    assert_text "Theme saved"
    assert_equal({ "light" => { "ring" => "oklch(0.6 0.1 30)" } }, @theme.reload.inputs["overrides"])
    assert_equal "oklch(0.6 0.1 30)", @theme.light["ring"]
  end

  test "a rejected Save re-renders the editor with the errors" do
    page.execute_script("document.querySelector('[name=\"theme[inputs][primary]\"]').value = 'oklch(2 0.2 250)'")
    click_on "Save"

    assert_selector :testid, "editor-errors", text: "Primary must be"
    assert_selector :testid, "preview-root"
    assert_equal "Zinc", @theme.reload.name
  end

  # An error in #editor-errors may legitimately wrap the toolbar onto a second line; this is the clean state.
  test "name, Save, Publish, Export and Describe a theme share one row above the groups" do
    nodes = [ find_field("Name"), *%w[save publish-toggle export describe].map { |id| find(:testid, id) } ]
    tops = nodes.map { |node| evaluate_script("Math.round(arguments[0].getBoundingClientRect().top)", node) }
    header_bottom = evaluate_script("arguments[0].getBoundingClientRect().bottom", find(:testid, "editor-header"))
    editor_top = evaluate_script("arguments[0].getBoundingClientRect().top", find(:testid, "editor"))

    assert_equal 1, tops.uniq.size, "the controls sit on #{tops.uniq.size} rows"
    assert_operator header_bottom - editor_top, :<=, 100
  end

  test "the describe trigger announces a dialog, points at its panel while open and drops the pointer on Escape" do
    trigger = find(:testid, "describe")

    assert_equal "dialog", trigger[:"aria-haspopup"]
    assert_nil trigger[:"aria-controls"]

    trigger.click

    assert_selector :testid, "generation-panel"
    assert_equal find(:testid, "generation-panel")[:id], find(:testid, "describe")[:"aria-controls"]

    find(:testid, "generation-panel").send_keys :escape

    assert_no_selector :testid, "generation-panel"
    assert_nil find(:testid, "describe")[:"aria-controls"]
    assert_equal "false", find(:testid, "describe")[:"aria-expanded"]
  end

  test "the describe dialog opens from the keyboard, lands on the prompt, tabs to Generate and returns focus on Escape" do
    evaluate_script("document.querySelector('[data-testid=describe]').focus()")
    page.driver.browser.keyboard.type(:enter)

    assert_selector :testid, "generation-panel"
    assert_equal "generation-prompt", evaluate_script("document.activeElement.id")

    page.driver.browser.keyboard.type("calm blue", :tab)

    assert_equal "generate", evaluate_script("document.activeElement.dataset.testid")
    assert_selector :testid, "generation-panel"

    page.driver.browser.keyboard.type(:escape)

    assert_no_selector :testid, "generation-panel"
    assert_equal "describe", evaluate_script("document.activeElement.dataset.testid")
  end

  test "the page switcher renders the other preview pages inside the preview root" do
    click_on "Settings"

    assert_selector "[data-testid=preview-root] h1", visible: :visible
  end

  private

  def open_group(key)
    find(:testid, "group-#{key}").click

    assert_selector :testid, "group-#{key}-panel"
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
