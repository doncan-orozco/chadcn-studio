require "test_helper"

class Exports::Presenter::SharingTest < ActiveSupport::TestCase
  def sharing(theme) = Exports::Presenter::Sharing.new(theme, base_url: "https://studio.test")

  test "a draft offers to share a link" do
    assert_equal "Share link", sharing(themes(:zinc)).publication_label
    assert_not sharing(themes(:zinc)).unpublish?
  end

  test "a published theme offers to stop sharing and exposes its export urls" do
    presenter = sharing(themes(:slate))

    assert_equal "Stop sharing", presenter.publication_label
    assert_predicate presenter, :unpublish?
    assert_equal "/themes/#{themes(:slate).id}/publication", presenter.publication_path
    assert_equal "/t/slate.css", presenter.css.path
    assert_equal "/t/slate.json", presenter.json.path
    assert_equal "bin/rails theme:import[https://studio.test/t/slate.css]", presenter.css.import_command
  end
end
