require "test_helper"

class Themes::Presenter::EditorTest < ActiveSupport::TestCase
  setup { @editor = Themes::Presenter::Editor.new(themes(:zinc)) }

  test "lists the seven groups of the sidebar" do
    assert_equal [ "Brand color", "Surfaces and text", "Radius", "Charts", "Sidebar", "Dark mode", "Advanced" ], @editor.groups.map(&:label)
    assert_equal "Charts", @editor.group("charts").label
  end

  test "offers the six preview pages, each a renderable view" do
    assert_equal Views::Previews::PAGES.keys, @editor.pages.map(&:key)
    assert_equal "dashboard", @editor.first_page
    assert(@editor.pages.all? { |page| page.view_class.new(page.presenter).respond_to?(:call) })
  end

  test "variables are CSS custom properties of valid colors and the radius" do
    light = @editor.variables("light")

    assert_equal "oklch(0.21 0.006 285.885)", light["--primary"]
    assert_equal "0.625rem", light["--radius"]
    assert_equal Chadcn::Theme::REQUIRED.size + 1, light.size
    assert_equal "oklch(1 0 0 / 10%)", @editor.variables("dark")["--border"]
    refute @editor.variables("dark").key?("--radius")
  end

  test "a stored value that is not a color never reaches a style attribute" do
    theme = themes(:zinc)
    theme.light = theme.light.merge("primary" => "red; background: url(x)", "radius" => "1px; x: y")
    variables = Themes::Presenter::Editor.new(theme).variables("light")

    refute variables.key?("--primary")
    refute variables.key?("--radius")
  end

  test "palette_json carries both modes for the preview controller" do
    assert_equal %i[light dark], @editor.palette_json.keys
  end

  test "derived wraps a derivation payload as an unsaved theme" do
    payload = Themes::Operation::Derive.new.call(inputs: { primary: "oklch(0.55 0.2 250)" }).value!
    editor = Themes::Presenter::Editor.derived(payload)

    assert_predicate editor, :new_record?
    assert_equal "oklch(0.55 0.2 250)", editor.variables("light")["--primary"]
    assert_equal "oklch(0.55 0.2 250)", editor.group("brand").summary
  end

  test "failures merge the model errors with a rejected derivation's messages" do
    assert_empty @editor.failures
    refute_predicate @editor, :failed?

    theme = Theme.new
    theme.errors.add(:base, "light: --foreground on --background is 1:1")
    from_list = Themes::Presenter::Editor.new(theme, failures: [ "dark: --muted-foreground on --muted is 2:1" ])
    from_hash = Themes::Presenter::Editor.new(Theme.new, failures: { primary: [ "must be an oklch color" ] })

    assert_equal [ "light: --foreground on --background is 1:1", "dark: --muted-foreground on --muted is 2:1" ], from_list.failures.map { |message| message.sub("Base ", "") }
    assert_equal [ "primary: must be an oklch color" ], from_hash.failures
    assert_predicate from_hash, :failed?
  end

  test "form values and paths" do
    assert_equal "oklch(0.21 0.006 285.885)", @editor.primary
    assert_equal "0.625rem", @editor.radius
    assert_equal "/themes/#{themes(:zinc).id}", @editor.save_path
    assert_equal "/derivations", @editor.derivations_path
    assert_equal "/derivations?controls=1", @editor.refresh_path
  end
end
