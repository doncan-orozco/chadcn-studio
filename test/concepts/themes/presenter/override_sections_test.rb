require "test_helper"

class Themes::Presenter::OverrideSectionsTest < ActiveSupport::TestCase
  setup { @sections = Themes::Presenter::OverrideSections.new(Themes::Presenter::Group.new(themes(:zinc), key: "advanced")) }

  test "the most used fields come first, then the sidebar groups in the sidebar's order" do
    assert_equal %w[most-used brand surfaces radius charts sidebar], @sections.sections("light").map(&:key)
    assert_equal %w[primary border ring], @sections.sections("light").first.overrides.map { |override| override.name.delete_prefix("--") }
  end

  test "every field of the mode lands in exactly one section" do
    %w[light dark].each do |mode|
      names = @sections.sections(mode).flat_map { |section| section.overrides.map(&:name) }

      assert_equal @sections.overrides(mode).map(&:name).sort, names.sort
    end
  end

  test "dark has no Radius section, its radius is the light one" do
    assert_not_includes @sections.sections("dark").map(&:key), "radius"
  end
end
