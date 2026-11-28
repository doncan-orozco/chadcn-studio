require "test_helper"

class Exports::Presenter::CssTest < ActiveSupport::TestCase
  BASE = "https://studio.test".freeze
  URL = "#{BASE}/t/slate.css".freeze

  test "holds the markers, a source line and the palette" do
    export = Exports::Presenter::Css.new(themes(:slate), base_url: BASE)
    lines = export.body.lines.map(&:chomp)

    assert_equal Chadcn::Theme::COLORS_START, lines.first
    assert_includes export.body, "/* source: chadcn-studio Slate #{URL} */"
    assert_includes lines, Chadcn::Theme::COLORS_END
    assert_equal themes(:slate).palette, Chadcn::Theme.parse(export.body)
  end

  test "a name cannot close the source comment" do
    theme = themes(:slate)
    theme.name = "x */ :root { --background: red; } /*"

    body = Exports::Presenter::Css.new(theme, base_url: BASE).body

    assert_equal 1, body.scan(%r{^/\* source:}).size
    assert_equal theme.palette, Chadcn::Theme.parse(body)
  end

  test "names the file, the content type and the import command" do
    export = Exports::Presenter::Css.new(themes(:slate), base_url: BASE)

    assert_equal "theme.css", export.filename
    assert_equal "Download theme.css", export.download_label
    assert_equal "Downloaded theme.css", export.downloaded_label
    assert_equal "text/css", export.content_type
    assert_equal "bin/rails theme:import[#{URL}]", export.import_command
  end

  test "its download path is the public URL once published and the draft export before" do
    published = Exports::Presenter::Css.new(themes(:slate), base_url: BASE)
    draft = Exports::Presenter::Css.new(themes(:zinc), base_url: BASE)

    assert_equal "/t/slate.css", published.download_path
    assert_equal "/t/zinc.css?draft=1", draft.download_path
  end
end
