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

  test "its download path is the public URL once published and the draft export before" do
    published = Exports::Presenter::Json.new(themes(:slate))
    draft = Exports::Presenter::Json.new(themes(:zinc))

    assert_equal "/t/slate.json", published.download_path
    assert_equal "/t/zinc.json?draft=1", draft.download_path
  end
end
