require "test_helper"

# The seam, not the strings: what the gem renders once it has merged HitArea over its own defaults. The measured size is
# proven in the browser (test/system/target_size_test.rb); this fails first when the gem changes a default that HitArea overrides.
class Components::Editor::HitAreaTest < ActiveSupport::TestCase
  test "the slider thumb keeps none of the gem's 16 px box, border, fill or box shadow" do
    classes = rendered(Components::Editor::SliderField.new(id: "demo", label: "Demo", value: 0.5, min: 0, max: 1, step: 0.1)).at_css("[role=slider]")["class"].split

    assert_empty classes & %w[size-4 border shadow-sm bg-white]
  end

  test "the switch keeps none of the gem's 18 px height" do
    classes = rendered(Components::Editor::ModeSwitch.new).at_css("[role=switch]")["class"].split

    assert_not_includes classes, "data-[size=default]:h-[1.15rem]"
  end

  test "the dialog Close keeps the gem's corner offset out and has no ::after box" do
    group = Themes::Presenter::Group.new(themes(:zinc), key: "surfaces")
    close = rendered(Components::Editor::GroupDialog.new(group:)).at_css("[data-chadcn--dialog-part=close]")

    assert_empty close["class"].split & %w[top-4 right-4]
    assert_no_match(/after:/, close["class"])
  end

  private

  def rendered(component)
    host = Class.new(Components::Base) { define_method(:view_template) { render(Chadcn::Sidebar::Provider.new { render component }) } }
    Nokogiri::HTML5.fragment(host.new.call)
  end
end
