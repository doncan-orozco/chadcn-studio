# Presenter Archetype Example

```ruby
# app/concepts/themes/presenter/card.rb
module Themes
  module Presenter
    class Card < ::Core::Presenter::Base
      def self.wrap(collection, mode: :light)
        collection.map { |theme| new(theme, mode: mode) }
      end

      attr_reader :mode

      def initialize(theme, mode: :light)
        super(theme)
        @mode = mode
      end

      def variables
        mode == :dark ? dark : light
      end

      def swatches
        %w[background primary secondary accent destructive].map { |name| [name, variables.fetch(name)] }
      end

      def radius_label
        "#{variables.fetch("radius", light.fetch("radius"))} radius"
      end

      def published_label
        published? ? "Published" : "Draft"
      end

      def path
        helpers.theme_path(__getobj__)
      end
    end
  end
end
```

```ruby
# test/concepts/themes/presenter/card_test.rb
require "test_helper"

class Themes::Presenter::CardTest < ActiveSupport::TestCase
  test "swatches read the mode's variables" do
    presenter = Themes::Presenter::Card.new(themes(:zinc), mode: :dark)

    assert_equal themes(:zinc).dark.fetch("primary"), presenter.swatches.to_h.fetch("primary")
  end

  test "wrap builds one presenter per theme" do
    presenters = Themes::Presenter::Card.wrap(Theme.all, mode: :light)

    assert_equal Theme.count, presenters.size
    assert presenters.all?(Themes::Presenter::Card)
  end
end
```

The presenter returns values (`swatches`, `published_label`) and paths; the component decides the markup and the classes.
