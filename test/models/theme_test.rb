require "test_helper"

class ThemeTest < ActiveSupport::TestCase
  test "every fixture theme is valid" do
    Theme.find_each { |theme| assert_predicate theme, :valid?, "#{theme.slug}: #{theme.errors.full_messages.to_sentence}" }
  end

  test "palette is a Chadcn::Theme::Palette of the stored modes" do
    palette = themes(:zinc).palette

    assert_instance_of Chadcn::Theme::Palette, palette
    assert_equal themes(:zinc).light, palette.root
    assert_equal themes(:zinc).dark, palette.dark
  end

  test "published? follows published_at" do
    assert_predicate themes(:slate), :published?
    assert_not_predicate themes(:zinc), :published?
  end

  test "a missing variable is invalid with the gem's error text" do
    theme = themes(:zinc)
    theme.light = theme.light.except("primary")

    assert_not theme.valid?
    assert_includes theme.errors[:base], "light (:root): missing primary"
  end

  test "an unsafe value is invalid with the gem's error text" do
    theme = themes(:zinc)
    theme.dark = theme.dark.merge("primary" => "red; } body { display: none")

    assert_not theme.valid?
    assert(theme.errors[:base].any? { |message| message.include?("could break theme.css") })
  end

  test "slug must be unique and URL-safe" do
    duplicate = themes(:zinc).dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"

    duplicate.slug = "Not Safe"
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "is invalid"
  end

  test "name is required" do
    theme = themes(:zinc).dup.tap { |copy| copy.name = "" }

    assert_not theme.valid?
    assert_includes theme.errors[:name], "can't be blank"
  end

  test "destroying a theme destroys its generations" do
    assert_difference -> { Generation.count }, -themes(:zinc).generations.count do
      themes(:zinc).destroy
    end
  end
end
