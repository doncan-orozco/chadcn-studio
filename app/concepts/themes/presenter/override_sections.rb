# frozen_string_literal: true

# The Advanced fields of one mode under the names of the sidebar groups: the three a person pins most first ("Most used"), then
# Brand color, Backgrounds... in the sidebar's order. Wraps the advanced group; a variable no section names is not shown.
class Themes::Presenter::OverrideSections < Core::Presenter::Base
  MOST_USED = "most-used"
  GROUPS = Themes::Presenter::Group::DEFINITIONS.except("advanced")
  LABELS = { MOST_USED => "Most used" }.merge(GROUPS.transform_values { |definition| definition[:label] }).freeze
  SECTION_BY_VARIABLE = GROUPS.each_with_object({}) { |(key, definition), index| definition[:variables].each { |variable| index[variable] = key } }
                              .merge(Themes::Presenter::Group::PINNED_FIRST.index_with(MOST_USED)).freeze

  private_constant :GROUPS, :LABELS, :SECTION_BY_VARIABLE

  Section = Data.define(:key, :label, :overrides)

  # The sections of the mode that have at least one field, each with its fields in the order the group gives them.
  def sections(mode)
    by_section = overrides(mode).group_by { |override| SECTION_BY_VARIABLE[override.name.delete_prefix("--")] }
    LABELS.filter_map { |key, label| Section.new(key: key, label: label, overrides: by_section[key]) if by_section[key] }
  end
end
