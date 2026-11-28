require "test_helper"

class Components::Editor::DerivedTest < ActiveSupport::TestCase
  setup do
    editor = Themes::Presenter::Editor.new(themes(:zinc))
    @page = Capybara.string(Components::Editor::Derived.new(editor).call)
  end

  test "Advanced is refreshed inside each mode's panel, never at the tabs, so the chosen mode survives" do
    assert @page.has_css?("turbo-stream[action=update][target=advanced-overrides-light]", visible: :all)
    assert @page.has_css?("turbo-stream[action=update][target=advanced-overrides-dark]", visible: :all)
    assert @page.has_no_css?("turbo-stream[target=advanced-overrides]", visible: :all)
  end

  test "the summary of every group is refreshed" do
    Themes::Presenter::Group::KEYS.each { |key| assert @page.has_css?("turbo-stream[target=summary-#{key}]", visible: :all) }
  end
end
