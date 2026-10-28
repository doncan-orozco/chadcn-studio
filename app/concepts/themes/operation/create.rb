# frozen_string_literal: true

# A name and a primary color -> a saved theme. Derives with the default inputs; nothing is saved unless the palette
# passes `Derive` (theme-science R5).
class Themes::Operation::Create < Core::Operation
  FALLBACK_SLUG = "theme"
  SLUG_ATTEMPTS = 3
  private_constant :FALLBACK_SLUG, :SLUG_ATTEMPTS

  def initialize(derive: Themes::Operation::Derive.new)
    @derive = derive
    super()
  end

  def call(name: nil, primary: nil)
    theme = Theme.new(name: name.to_s.strip, inputs: { "primary" => primary.to_s.strip })
    derivation = derive(theme)
    theme.assign_attributes(light: derivation[:palette].root, dark: derivation[:palette].dark, inputs: derivation[:inputs])
    step persist(theme)

    { model: theme }
  end

  private

  def derive(theme)
    outcome = @derive.call(inputs: { primary: theme.inputs["primary"] })
    return outcome.value! if outcome.success?

    failure = outcome.failure
    name_errors = name_errors(theme)
    inject_errors!(theme, failure[:code] == :invalid ? failure[:errors] : { primary: failure[:errors] })
    inject_errors!(theme, name: name_errors)
    fail_with_model!(theme, code: failure[:code])
  end

  # The model owns the name rules; the palette is not derived yet, so only its name errors are relevant.
  def name_errors(theme)
    theme.validate
    theme.errors[:name].dup.tap { theme.errors.clear }
  end

  # The unique index is the arbiter: a lost slug race takes the next free slug, a bounded number of times.
  def persist(theme, attempt: 1)
    theme.slug = unique_slug(theme.name)
    return Success(theme) if theme.save
    return persist(theme, attempt: attempt + 1) if theme.errors.of_kind?(:slug, :taken) && attempt < SLUG_ATTEMPTS

    Failure(model: theme, errors: model_errors(theme), code: :invalid)
  rescue ActiveRecord::RecordNotUnique
    raise if attempt >= SLUG_ATTEMPTS

    persist(theme, attempt: attempt + 1)
  end

  def unique_slug(name)
    base = name.parameterize.presence || FALLBACK_SLUG
    return base unless Theme.exists?(slug: base)

    suffix = (2..).find { |number| !Theme.exists?(slug: "#{base}-#{number}") }
    "#{base}-#{suffix}"
  end
end
