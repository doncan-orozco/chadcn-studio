# frozen_string_literal: true

# The editor page of a theme: its groups, the preview pages, the variables the preview root carries and any failures.
class Themes::Presenter::Editor < Core::Presenter::Base
  RADIUS = /\A\d+(?:\.\d+)?rem\z/
  private_constant :RADIUS

  Page = Data.define(:key, :label, :view)

  # A derivation that is not saved yet, shown with the same groups and variables as a saved theme.
  def self.derived(payload)
    new(Theme.new(light: payload[:palette].root, dark: payload[:palette].dark, inputs: payload[:inputs].deep_stringify_keys))
  end

  # `failures` are the errors of a rejected derivation: a hash of field => messages or a list of messages.
  def initialize(theme, failures: nil)
    super(theme)
    @failures = failures
  end

  def groups = @groups ||= Themes::Presenter::Group.all(__getobj__)

  def group(key) = groups.find { |group| group.key == key }

  def pages
    @pages ||= Views::Previews::PAGES.map do |key, (view_class, presenter_class)|
      Page.new(key: key, label: key.humanize, view: view_class.new(presenter_class.new))
    end
  end

  def first_page = pages.first.key

  # CSS custom properties of a mode, only values that parse as a color or a rem length: they end up in a `style` attribute.
  def variables(mode)
    palette = mode == "dark" ? dark : light
    palette.each_with_object({}) do |(name, value), result|
      safe = safe_value(name, value)
      result["--#{name}"] = safe if safe
    end
  end

  def palette_json = { light: variables("light"), dark: variables("dark") }

  def failures
    own = errors.full_messages
    posted = case @failures
    when Hash then @failures.flat_map { |field, messages| Array(messages).map { |message| "#{field}: #{message}" } }
    else Array(@failures)
    end
    own + posted
  end

  def failed? = failures.any?

  def primary = groups.first.primary
  def tint = groups.first.tint
  def radius = light["radius"].to_s

  def save_path = helpers.theme_path(__getobj__)
  def derivations_path = helpers.derivations_path
  def title = "Edit #{name}"

  private

  def safe_value(name, value)
    return value.to_s if name == "radius" && RADIUS.match?(value.to_s)

    Themes::Oklch.parse(value).to_s
  rescue Themes::Oklch::Invalid
    nil
  end
end
