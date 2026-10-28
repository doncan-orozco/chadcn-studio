# frozen_string_literal: true

# A name and a primary color -> a saved theme. Derives with the default inputs; nothing is saved unless the palette
# passes `Derive` (theme-science R5).
class Themes::Operation::Create < Core::Operation
  FALLBACK_SLUG = "theme"
  private_constant :FALLBACK_SLUG

  def initialize(derive: Themes::Operation::Derive.new)
    @derive = derive
    super()
  end

  def call(name:, primary:)
    theme = Theme.new(name: name.to_s.strip, inputs: { "primary" => primary.to_s.strip })
    derivation = derive(theme)
    theme.assign_attributes(light: derivation[:palette].root, dark: derivation[:palette].dark, inputs: derivation[:inputs], slug: unique_slug(theme.name))
    step persist(theme)

    { model: theme }
  end

  private

  def derive(theme)
    outcome = @derive.call(inputs: { primary: theme.inputs["primary"] })
    return outcome.value! if outcome.success?

    failure = outcome.failure
    inject_errors!(theme, failure[:code] == :invalid ? failure[:errors] : { primary: failure[:errors] })
    theme.errors.add(:name, :blank) if theme.name.blank?
    fail_with_model!(theme, code: failure[:code])
  end

  def persist(theme)
    return Success(theme) if theme.save

    Failure(model: theme, errors: model_errors(theme), code: :invalid)
  end

  def unique_slug(name)
    base = name.parameterize.presence || FALLBACK_SLUG
    return base unless Theme.exists?(slug: base)

    suffix = (2..).find { |number| !Theme.exists?(slug: "#{base}-#{number}") }
    "#{base}-#{suffix}"
  end
end
