require "test_helper"

class Generations::Presenter::PanelTest < ActiveSupport::TestCase
  test "for loads the latest generation of the theme as its status" do
    theme = generations(:pending).theme
    newest = theme.generations.create!(prompt: "newest")

    assert_equal newest, Generations::Presenter::Panel.for(theme).status.__getobj__
  end

  test "a theme with no generation has no status" do
    assert_nil Generations::Presenter::Panel.new(themes(:blue)).status
  end

  test "exposes the prompt field settings" do
    panel = Generations::Presenter::Panel.new(themes(:blue))

    assert_equal "generation[prompt]", panel.prompt_param
    assert_equal 2000, panel.prompt_limit
    assert_predicate panel.prompt_placeholder, :present?
  end
end
