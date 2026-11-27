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

  test "no entries gives no groups" do
    presenter = Gallery::Presenter::Index.new(entries: [])

    assert_empty presenter.groups
    assert_equal 0, presenter.count
  end

  test "entries given out of order are sorted, so the group letters are too" do
    entries = %w[Zebra Apple Mango].map { |title| Struct.new(:title).new(title) }
    presenter = Gallery::Presenter::Index.new(entries:)

    assert_equal %w[A M Z], presenter.groups.map(&:letter)
  end
end
