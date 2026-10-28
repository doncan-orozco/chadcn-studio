require "test_helper"

class Themes::Operation::CreateTest < ActiveSupport::TestCase
  include PaletteAssertions

  test "saves a theme whose palette validates strictly" do
    theme = assert_difference("Theme.count", 1) { Themes::Operation::Create.new.call(name: "Ocean", primary: "oklch(0.55 0.2 250)").value![:model] }

    assert_predicate theme, :persisted?
    assert_equal "ocean", theme.slug
    assert_valid_palette theme.palette
    assert_equal "oklch(0.55 0.2 250)", theme.light["primary"]
  end

  test "a taken slug gets the next free suffix" do
    2.times { Themes::Operation::Create.new.call(name: "Zinc", primary: "oklch(0.55 0.2 250)").value! }

    assert_equal %w[zinc-2 zinc-3], Theme.where(slug: %w[zinc-2 zinc-3]).order(:slug).pluck(:slug)
  end

  test "a name with no letters falls back to a slug" do
    assert_equal "theme", Themes::Operation::Create.new.call(name: "!!!", primary: "oklch(0.55 0.2 250)").value![:model].slug
  end

  test "an out-of-range color fails with :invalid and saves nothing" do
    failure = assert_no_difference("Theme.count") { Themes::Operation::Create.new.call(name: "Bad", primary: "oklch(2 0.2 250)").failure }

    assert_equal :invalid, failure[:code]
    assert_predicate failure[:model].errors[:primary], :any?
    assert_equal "Bad", failure[:model].name
  end

  test "a color that cannot meet the contrast gate fails with its code on :primary" do
    derive = Struct.new(:outcome) { def call(**) = outcome }.new(Dry::Monads::Failure(code: :contrast, errors: [ "light: --primary on --background is 2:1" ]))
    failure = Themes::Operation::Create.new(derive: derive).call(name: "Pale", primary: "oklch(0.9 0.1 250)").failure

    assert_equal :contrast, failure[:code]
    assert_includes failure[:model].errors[:primary].join, "--primary on --background"
  end

  test "a blank name fails and a color error is reported with it" do
    failure = Themes::Operation::Create.new.call(name: " ", primary: "blue").failure

    assert_equal %i[name primary], failure[:model].errors.attribute_names.sort
  end

  test "a blank name with a good color fails on the model" do
    failure = Themes::Operation::Create.new.call(name: "", primary: "oklch(0.55 0.2 250)").failure

    assert_equal [ :name ], failure[:model].errors.attribute_names
  end
end
