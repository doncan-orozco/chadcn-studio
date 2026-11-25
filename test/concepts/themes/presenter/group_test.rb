require "test_helper"

class Themes::Presenter::GroupTest < ActiveSupport::TestCase
  setup { @theme = themes(:zinc) }

  test "the groups partition the gem's variable set without dropping or inventing one" do
    covered = %w[brand surfaces charts sidebar].flat_map { |key| Themes::Presenter::Group.new(@theme, key: key).variables }

    assert_equal Chadcn::Theme::REQUIRED.sort, covered.sort
    assert_equal [ "radius" ], Themes::Presenter::Group.new(@theme, key: "radius").variables
    assert_equal Themes::Presenter::Group::KEYS, Themes::Presenter::Group.all(@theme).map(&:key)
  end

  test "an unknown group is refused" do
    assert_raises(ArgumentError) { Themes::Presenter::Group.new(@theme, key: "nope") }
  end

  test "rows carry the light and dark value of each variable with a swatch" do
    row = Themes::Presenter::Group.new(@theme, key: "brand").rows.find { |candidate| candidate.name == "--primary" }

    assert_equal @theme.light["primary"], row.light
    assert_equal @theme.dark["primary"], row.dark
    assert_equal "background-color: #{@theme.light['primary']}", row.light_style
  end

  test "rows link to the theme page under All values" do
    assert_equal "/themes/#{@theme.id}#all-values", Themes::Presenter::Group.new(@theme, key: "brand").values_path
  end

  test "an unsaved theme has no All values link" do
    assert_nil Themes::Presenter::Group.new(Theme.new(light: @theme.light, dark: @theme.dark), key: "brand").values_path
  end

  test "the brand group exposes the primary as the three numbers the sliders move" do
    group = Themes::Presenter::Group.new(@theme, key: "brand")

    assert_equal "oklch(0.21 0.006 285.885)", group.summary
    assert_in_delta 0.21, group.lightness
    assert_in_delta 0.006, group.chroma
    assert_in_delta 285.885, group.hue
  end

  test "a primary that is not a color falls back to a neutral midpoint instead of failing the editor" do
    @theme.inputs = { "primary" => "blue" }
    group = Themes::Presenter::Group.new(@theme, key: "brand")

    assert_in_delta 0.5, group.lightness
    assert_in_delta 0.0, group.chroma
  end

  test "radius and tint read the stored values or the rule's default" do
    assert_in_delta 0.625, Themes::Presenter::Group.new(@theme, key: "radius").radius_rem
    assert_equal "0.625rem", Themes::Presenter::Group.new(@theme, key: "radius").summary
    assert_in_delta Themes::Service::Harmony::DEFAULTS[:tint], Themes::Presenter::Group.new(@theme, key: "surfaces").tint
  end

  test "advanced fields list the overridable variables of a mode and mark the overridden ones" do
    @theme.inputs = { "primary" => "oklch(0.55 0.2 250)", "overrides" => { "light" => { "ring" => "oklch(0.6 0.1 30)", "chart-1" => "" } } }
    group = Themes::Presenter::Group.new(@theme, key: "advanced")
    light = group.overrides("light")
    ring = light.find { |field| field.name == "--ring" }

    assert_predicate ring, :overridden?
    assert_equal "oklch(0.6 0.1 30)", ring.value
    assert_equal "theme[inputs][overrides][light][ring]", ring.field_name
    assert_equal "oklch(0.705 0.015 286.067)", ring.derived
    refute_predicate light.find { |field| field.name == "--chart-1" }, :overridden?
    refute_includes light.map(&:name), "--destructive"
    assert_equal "1 overridden", group.summary
    refute_includes group.overrides("dark").map(&:name), "--radius"
  end

  test "without overrides the advanced summary says what the group is for" do
    assert_equal "Set one color by hex", Themes::Presenter::Group.new(@theme, key: "advanced").summary
  end

  test "advanced lists primary, border and ring first, then the rest, radius last" do
    names = Themes::Presenter::Group.new(@theme, key: "advanced").overrides("light").map(&:name)

    assert_equal %w[--primary --border --ring], names.first(3)
    assert_equal "--radius", names.last
    assert_equal Themes::Presenter::Group.new(@theme, key: "advanced").variables.size - 1, names.size
    assert_equal names.uniq, names
  end

  test "a group's trigger id is the one panel links name" do
    assert_equal "group-advanced-trigger", Themes::Presenter::Group.new(@theme, key: "advanced").trigger_id
    assert_equal Themes::Presenter::Group.trigger_id("surfaces"), Themes::Presenter::Group.new(@theme, key: "surfaces").trigger_id
  end

  test "only the groups of read-only rows point to Advanced" do
    pinnable = Themes::Presenter::Group.all(@theme).select(&:pinnable?).map(&:key)

    assert_equal %w[surfaces charts sidebar], pinnable
  end

  test "controls ids are the stream targets of the brand and advanced panels" do
    assert_equal "brand-controls", Themes::Presenter::Group.new(@theme, key: "brand").controls_id
    assert_equal "advanced-overrides", Themes::Presenter::Group.new(@theme, key: "advanced").controls_id
  end
end
