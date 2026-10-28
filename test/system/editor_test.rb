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

  test "a rejected Save re-renders the editor with the errors" do
    page.execute_script("document.querySelector('[name=\"theme[inputs][primary]\"]').value = 'oklch(2 0.2 250)'")
    click_on "Save"

    assert_selector :testid, "editor-errors", text: "Primary must be"
    assert_selector :testid, "preview-root"
    assert_equal "Zinc", @theme.reload.name
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

  def close_group
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
