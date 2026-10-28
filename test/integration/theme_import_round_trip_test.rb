require "test_helper"
require "tmpdir"

# The export is the input of `bin/rails theme:import`: a published theme's CSS imported into a theme.css passes strict check.
class ThemeImportRoundTripTest < ActionDispatch::IntegrationTest
  def with_theme_dir
    original = Chadcn.config.theme_dir
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "theme.css"), File.read(File.join(original, "theme.css")))
      Chadcn.config.theme_dir = dir
      yield dir
    end
  ensure
    Chadcn.config.theme_dir = original
  end

  test "the exported CSS imports and passes strict check" do
    theme = Themes::Operation::Create.new.call(name: "Ocean", primary: "oklch(0.55 0.2 250)").value![:model]
    Themes::Operation::Publish.new.call(model: theme)
    get theme_export_path(theme.slug, format: "css")

    with_theme_dir do |dir|
      source = File.join(dir, "export.css")
      File.write(source, response.body)

      result = Chadcn::Theme.import(source)

      assert_empty result[:errors]
      assert_empty result[:filled]
      assert_empty Chadcn::Theme.check(strict: true)[:errors]
      assert_equal theme.palette, Chadcn::Theme.parse(File.read(Chadcn::Theme.theme_file))
    end
  end

  test "the JSON export's inputs create a theme with the same palette" do
    original = Themes::Operation::Create.new.call(name: "Ocean", primary: "oklch(0.55 0.2 250)").value![:model]
    Themes::Operation::Publish.new.call(model: original)

    get theme_export_path(original.slug, format: "json")
    data = JSON.parse(response.body)
    again = Themes::Operation::Create.new.call(name: "Ocean again", primary: data["inputs"]["primary"]).value![:model]

    assert_equal data["light"], again.light
    assert_equal data["dark"], again.dark
  end
end
