require "test_helper"

class Components::Editor::OverrideFieldsTest < ActiveSupport::TestCase
  setup do
    group = Themes::Presenter::Group.new(themes(:zinc), key: "advanced")
    @sections = Themes::Presenter::OverrideSections.new(group)
    @page = Capybara.string(Components::Editor::OverrideFields.new(mode: "light", sections: @sections.sections("light")).call)
  end

  test "a heading for each section passed, in order, each naming its fields" do
    assert_equal @sections.sections("light").map(&:label), @page.all("h3").map(&:text)
    assert_equal @sections.sections("light").first.overrides.size, @page.first("section").all("[data-variable]").size
  end

  test "every field of the mode is a row named by its variable" do
    assert_equal @sections.overrides("light").map { |override| override.name.delete_prefix("--") }.sort, @page.all("[data-variable]").map { |row| row["data-variable"] }.sort
  end
end
