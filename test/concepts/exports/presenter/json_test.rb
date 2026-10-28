require "test_helper"

class Exports::Presenter::JsonTest < ActiveSupport::TestCase
  test "holds name, slug, inputs and both palettes" do
    theme = themes(:slate)
    data = JSON.parse(Exports::Presenter::Json.new(theme).body)

    assert_equal "Slate", data["name"]
    assert_equal "slate", data["slug"]
    assert_equal theme.inputs, data["inputs"]
    assert_equal theme.light, data["light"]
    assert_equal theme.dark, data["dark"]
  end

  test "names the file and the content type" do
    export = Exports::Presenter::Json.new(themes(:slate))

    assert_equal "slate.json", export.filename
    assert_equal "application/json", export.content_type
  end
end
