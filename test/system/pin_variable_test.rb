require "application_system_test_case"

# Closed panels are hidden by a class, not by markup: the compiled stylesheet must be current.
require "rake"
Rails.application.load_tasks unless Rake::Task.task_defined?("tailwindcss:build")
Rake::Task["tailwindcss:build"].invoke

# From a variable in a read-only group to its field in Advanced, without scrolling a 63-field list.

class PinVariableTest < ApplicationSystemTestCase
  setup { visit edit_theme_path(themes(:zinc)) }

  test "Surfaces points to Advanced and the button opens it" do
    find(:testid, "group-surfaces").click

    assert_text "To set one exactly, use Advanced"
    within(:testid, "group-surfaces-panel") { click_on "Open Advanced" }

    assert_selector :testid, "group-advanced-panel"
    assert_no_selector :testid, "group-surfaces-panel", visible: :visible
    assert_selector "[data-state=open][data-slot=dialog-content]", count: 1
    assert_equal Components::Editor::VariableFilter::ID, evaluate_script("document.activeElement.id"), "focus lands on Find a variable"
  end

  test "Advanced lists primary, border and ring first and the sublabel says what it is for" do
    assert_selector "#summary-advanced", text: "Set one color by hex"
    find(:testid, "group-advanced").click

    assert_equal %w[primary border ring], all(:testid, "override-row", visible: :visible).first(3).map { |row| row["data-variable"] }
  end

  test "Find a variable narrows the list, keeps the other fields in the form and says when nothing matches" do
    find(:testid, "group-advanced").click
    fill_in "Find a variable", with: "ring"

    assert_selector :testid, "override-row", visible: :visible, minimum: 2
    assert_equal [ "ring", "sidebar-ring" ], all(:testid, "override-row", visible: :visible).map { |row| row["data-variable"] }.uniq
    assert_selector "input[name='theme[inputs][overrides][light][border]']", visible: :all

    fill_in "Find a variable", with: "zzz"

    assert_text "No variable matches"
  end

  test "the filter survives a re-derivation" do
    find(:testid, "group-advanced").click
    fill_in "Find a variable", with: "ring"
    fill_in "override-light-ring", with: "oklch(0.6 0.1 30)"
    find_field("override-light-ring").send_keys(:enter)

    assert_selector :testid, "overridden", count: 1
    assert_equal [ "ring", "sidebar-ring" ], all(:testid, "override-row", visible: :visible).map { |row| row["data-variable"] }.uniq
  end

  test "filtering is not an edit" do
    find(:testid, "group-advanced").click
    fill_in "Find a variable", with: "ring"
    find_field("Find a variable").send_keys(:tab)

    assert_equal [ "ring", "sidebar-ring" ], all(:testid, "override-row", visible: :visible).map { |row| row["data-variable"] }.uniq
    assert_no_selector :testid, "unsaved"
  end
end
