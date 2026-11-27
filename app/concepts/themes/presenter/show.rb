# frozen_string_literal: true

# A theme's palette, light and dark side by side, one row per variable; `sections` lists the brand variables first because they are what
# people look up.
class Themes::Presenter::Show < Core::Presenter::Base
  Section = Data.define(:heading, :slug, :rows)

  def rows = rows_by_variable.values

  def sections
    brand, other = variables.partition { |variable| Themes::Presenter::Group.brand?(variable) }
    [ section("Brand", "brand", brand), section("Everything else", "other", other) ]
  end

  def title = name
  def edit_path = helpers.edit_theme_path(__getobj__)
  def delete_label = "Delete #{name}"
  def summary = "#{published? ? 'Published' : 'Draft'} theme, #{variables.size} variables."

  private

  def variables = Chadcn::Theme::REQUIRED + Chadcn::Theme::ROOT_ONLY

  def rows_by_variable
    @rows_by_variable ||= variables.to_h { |variable| [ variable, Themes::Presenter::Variable.row(variable, light: light[variable], dark: dark[variable]) ] }
  end

  def section(heading, slug, names)
    Section.new(heading: heading, slug: slug, rows: rows_by_variable.values_at(*names))
  end
end
