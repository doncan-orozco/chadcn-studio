require "test_helper"

class Themes::DerivationsControllerTest < ActionDispatch::IntegrationTest
  def derive(**inputs)
    post derivations_path, params: { theme: { inputs: inputs } }
  end

  test "POST /derivations answers a Turbo Stream with the derived palette and the group summaries" do
    derive(primary: "oklch(0.55 0.2 250)", tint: "0.4", radius: "0.5rem")

    assert_response :success
    assert_equal Mime[:turbo_stream], response.media_type
    assert_select "turbo-stream[action=update][target=editor-palette]"
    assert_select "turbo-stream[target=summary-brand] template", text: "oklch(0.55 0.2 250)"
    assert_select "turbo-stream[target=summary-radius] template", text: "0.5rem"
    assert_select "turbo-stream[target=rows-charts] template li", count: 5
    assert_select "turbo-stream[target=advanced-overrides] template [data-testid=override-row]", minimum: 30
    assert_select "turbo-stream[target=editor-errors] template", text: ""
  end

  test "the palette source holds a whole palette in both modes" do
    derive(primary: "oklch(0.55 0.2 250)")
    source = Nokogiri::HTML5.fragment(css_select("turbo-stream[target=editor-palette] template").first.inner_html).at_css("[data-testid=palette-source]")

    assert_equal "oklch(0.55 0.2 250)", JSON.parse(source["data-light"])["--primary"]
    assert_equal Chadcn::Theme::REQUIRED.size, JSON.parse(source["data-dark"]).size
  end

  test "overrides survive the derivation and show as overridden; a cleared one does not" do
    derive(primary: "oklch(0.55 0.2 250)", overrides: { light: { ring: "oklch(0.6 0.1 30)", "chart-1": "" } })

    assert_response :success
    assert_select "turbo-stream[target=advanced-overrides] template [data-overridden=true]", count: 1
    assert_select "turbo-stream[target=summary-advanced] template", text: "1 overridden"
    assert_includes response.body, "oklch(0.6 0.1 30)"
  end

  test "controls=1 redraws the brand controls at the derived color" do
    post derivations_path(controls: 1), params: { theme: { inputs: { primary: "oklch(0.55 0.2 250)" } } }

    assert_select "turbo-stream[target=brand-controls] template [data-testid=primary-lightness]"
  end

  test "without controls=1 the brand controls are left alone" do
    derive(primary: "oklch(0.55 0.2 250)")

    assert_select "turbo-stream[target=brand-controls]", count: 0
  end

  test "an out-of-range color answers 422 with the errors and no palette" do
    derive(primary: "oklch(2 0.2 250)")

    assert_response :unprocessable_entity
    assert_equal Mime[:turbo_stream], response.media_type
    assert_select "turbo-stream[target=editor-errors] template li", text: /primary: /
    assert_select "turbo-stream[target=editor-palette]", count: 0
  end

  test "a contrast failure lists the failing pair" do
    derive(primary: "oklch(0.55 0.2 250)", overrides: { light: { foreground: "oklch(1 0 0)" } })

    assert_response :unprocessable_entity
    assert_select "turbo-stream[target=editor-errors] template li", text: /--foreground on --background/
  end

  test "writes nothing" do
    assert_no_difference("Theme.count") { derive(primary: "oklch(0.55 0.2 250)") }
  end
end
