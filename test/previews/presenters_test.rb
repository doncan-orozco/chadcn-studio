require "test_helper"

class PreviewPresentersTest < ActiveSupport::TestCase
  test "every page has a title" do
    Views::Previews::PAGES.each do |page, (_view, presenter)|
      assert_predicate presenter.new.title, :present?, page
    end
  end

  test "dashboard paid orders are only the paid ones" do
    assert_equal [ "Paid" ], Previews::Presenter::Dashboard.new.paid_orders.map(&:status).uniq
  end

  test "settings marks exactly one active section" do
    assert_equal [ "profile" ], Previews::Presenter::Settings.new.sections.select(&:active).map(&:key)
  end

  test "shell groups carry their titles and one active entry" do
    presenter = Previews::Presenter::Shell.new

    assert_equal %w[Platform Projects], presenter.groups.map(&:title)
    assert_equal 1, presenter.groups.flat_map(&:entries).count(&:active)
    assert_equal "A", presenter.product_initial
  end

  test "landing tiers build their call to action" do
    assert_equal "Choose Team", Previews::Presenter::Landing.new.tiers.second.cta_label
  end

  test "form plans summarise label and description" do
    assert_equal "Pro: For growing teams.", Previews::Presenter::Form.new.plans.last.summary
  end

  test "auth composes the sign-in title from the product" do
    assert_equal "Sign in to Acme", Previews::Presenter::Auth.new.sign_in_title
  end
end
