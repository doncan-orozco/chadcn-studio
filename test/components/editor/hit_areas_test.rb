require "test_helper"

class Components::Editor::HitAreasTest < ActiveSupport::TestCase
  test "the All brand variables summary is a block with vertical padding, a target over 24 px" do
    summary = render_group("brand").at_css("summary")

    assert_includes summary["class"].split, "block"
    assert_includes summary["class"].split, "py-1"
  end

  test "the See all values link pads itself to a target over 24 px" do
    link = render_group("surfaces").at_css("[data-testid=all-values-link]")

    assert_includes link["class"].split, "inline-block"
    assert_includes link["class"].split, "py-1"
  end

  private

  def render_group(key)
    dialog = Components::Editor::GroupDialog.new(group: Themes::Presenter::Group.new(themes(:zinc), key:))
    host = Class.new(Components::Base) { define_method(:view_template) { render(Chadcn::Sidebar::Provider.new { render dialog }) } }
    Nokogiri::HTML5.fragment(host.new.call)
  end
end
