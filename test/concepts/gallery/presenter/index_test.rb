require "test_helper"

class Gallery::Presenter::IndexTest < ActiveSupport::TestCase
  setup { @presenter = Gallery::Presenter::Index.new }

  test "filter_key is the lower-cased title" do
    entry = Struct.new(:title).new("Alert Dialog")

    assert_equal "alert dialog", @presenter.filter_key(entry)
  end

  test "groups hold every entry under its upper-cased initial" do
    assert_equal @presenter.entries.size, @presenter.groups.sum { |group| group.entries.size }
    assert(@presenter.groups.all? { |group| group.entries.all? { |entry| entry.title[0].upcase == group.letter } })
  end
end
