require "test_helper"

class Themes::Operation::UpdateTest < ActiveSupport::TestCase
  include PaletteAssertions

  setup { @theme = themes(:zinc) }

  test "saves the name and a palette derived from the posted inputs" do
    model = Themes::Operation::Update.new.call(model: @theme, params: { "name" => " Ocean ", "inputs" => { "primary" => "oklch(0.55 0.2 250)", "tint" => "0.2", "radius" => "0.5rem" } }).value![:model].reload

    assert_equal "Ocean", model.name
    assert_equal "oklch(0.55 0.2 250)", model.inputs["primary"]
    assert_in_delta 0.2, model.inputs["tint"]
    assert_equal "0.5rem", model.light["radius"]
    assert_valid_palette model.palette
  end

  test "persists light, dark and inputs together" do
    before = @theme.dark["primary"]
    Themes::Operation::Update.new.call(model: @theme, params: { "inputs" => { "primary" => "oklch(0.55 0.2 250)" } }).value!
    saved = Theme.find(@theme.id)

    assert_equal "oklch(0.55 0.2 250)", saved.light["primary"]
    refute_equal before, saved.dark["primary"]
    assert_equal "oklch(0.55 0.2 250)", saved.inputs["primary"]
  end

  test "inputs that are not posted keep their stored value, overrides included" do
    @theme.update_columns(inputs: { "primary" => "oklch(0.55 0.2 250)", "overrides" => { "light" => { "ring" => "oklch(0.6 0.1 30)" } } })
    model = Themes::Operation::Update.new.call(model: @theme, params: { "inputs" => { "tint" => "0.1" } }).value![:model].reload

    assert_equal "oklch(0.6 0.1 30)", model.light["ring"]
    assert_equal({ "light" => { "ring" => "oklch(0.6 0.1 30)" } }, model.inputs["overrides"])
  end

  test "posted overrides replace the stored ones and a cleared field re-derives the variable" do
    @theme.update_columns(inputs: { "primary" => "oklch(0.55 0.2 250)", "overrides" => { "light" => { "ring" => "oklch(0.6 0.1 30)" } } })
    overrides = { "light" => { "ring" => "", "chart-1" => "oklch(0.7 0.1 10)" } }
    model = Themes::Operation::Update.new.call(model: @theme, params: { "inputs" => { "overrides" => overrides } }).value![:model].reload

    assert_equal({ "light" => { "chart-1" => "oklch(0.7 0.1 10)" } }, model.inputs["overrides"])
    assert_equal "oklch(0.7 0.1 10)", model.light["chart-1"]
    refute_equal "oklch(0.6 0.1 30)", model.light["ring"]
  end

  test "an out-of-range color fails with :invalid, keeps the posted inputs on the model and saves nothing" do
    failure = Themes::Operation::Update.new.call(model: @theme, params: { "name" => "Bad", "inputs" => { "primary" => "oklch(2 0.2 250)" } }).failure

    assert_equal :invalid, failure[:code]
    assert_predicate failure[:model].errors[:primary], :any?
    assert_equal "oklch(2 0.2 250)", failure[:model].inputs["primary"]
    assert_equal "Zinc", Theme.find(@theme.id).name
  end

  test "an override that breaks the contrast fails with :contrast and lists the failing pair" do
    overrides = { "light" => { "foreground" => "oklch(1 0 0)" } }
    failure = Themes::Operation::Update.new.call(model: @theme, params: { "inputs" => { "primary" => "oklch(0.55 0.2 250)", "overrides" => overrides } }).failure

    assert_equal :contrast, failure[:code]
    assert_includes failure[:model].errors[:base].join, "--foreground on --background"
    assert_equal "oklch(0.141 0.005 285.823)", Theme.find(@theme.id).light["foreground"]
  end

  test "a blank name fails on the model" do
    failure = Themes::Operation::Update.new.call(model: @theme, params: { "name" => " ", "inputs" => { "primary" => "oklch(0.55 0.2 250)" } }).failure

    assert_equal :invalid, failure[:code]
    assert_predicate failure[:model].errors[:name], :any?
  end
end
