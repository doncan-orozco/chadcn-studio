require "test_helper"

class Core::Presenter::BaseTest < ActiveSupport::TestCase
  Item = Struct.new(:name)

  class Card < Core::Presenter::Base
    def shout = "#{name.upcase}!"
    def path = helpers.root_path
  end

  test "delegates to the wrapped object and exposes it" do
    item = Item.new("zinc")
    card = Card.new(item)

    assert_equal "zinc", card.name
    assert_same item, card.__getobj__
    assert_equal "ZINC!", card.shout
  end

  test "helpers gives route helpers" do
    assert_equal "/", Card.new(Item.new("zinc")).path
  end

  test "wrap builds one presenter per item" do
    cards = Card.wrap([ Item.new("a"), Item.new("b") ])

    assert_equal %w[a b], cards.map(&:name)
    assert(cards.all?(Card))
  end
end
