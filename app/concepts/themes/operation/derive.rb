# frozen_string_literal: true

# Inputs -> full palette. Writes nothing (theme-science R5, R8): contract, harmony rule, strict validation.
class Themes::Operation::Derive < Core::Operation
  def initialize(contract: Themes::Contract::Inputs.new, service: Themes::Service::Harmony)
    @contract = contract
    @service = service
    super()
  end

  def call(inputs:)
    values = step validate(inputs)
    derivation = @service.derive(values)
    warnings = step judge(derivation.palette)

    { palette: derivation.palette, inputs: values, repairs: derivation.repairs, warnings: warnings }
  end

  private

  def judge(palette)
    report = Chadcn::Theme.validate(palette, strict: true)
    errors = report[:errors] + unjudged_pairs(palette)
    return Success(report[:warnings]) if errors.empty?

    Failure(code: :contrast, errors: errors)
  end

  # A pair the gem cannot measure would pass the gate silently; it fails instead.
  def unjudged_pairs(palette)
    { "light" => palette.root, "dark" => palette.dark }.flat_map do |mode, variables|
      Chadcn::Theme::CONTRAST_PAIRS.filter_map do |foreground, surface|
        "#{mode}: --#{foreground} on --#{surface} cannot be judged" if Chadcn::Theme.contrast(variables[foreground], variables[surface]).nil?
      end
    end
  end

  def validate(inputs)
    outcome = @contract.call(inputs.to_h)
    return Success(canonical(outcome.to_h)) if outcome.success?

    Failure(code: :invalid, errors: outcome.errors.to_h)
  end

  # A color typed as hex becomes oklch here, so the stored inputs and the palette speak one color space.
  def canonical(values)
    primary = Themes::Oklch.parse(values[:primary])
    values = values.merge(primary: primary.to_s, primary_hex: typed_hex(values[:primary], values[:primary_hex], primary)).compact
    return values unless values[:overrides]

    values.merge(overrides: values[:overrides].transform_values { |variables| variables.to_h.transform_values { |color| Themes::Oklch.parse(color).to_s } })
  end

  # The hex the person typed, kept so the editor can show it back: oklch stored at three decimals cannot reproduce it.
  # A primary typed as hex is the newest one and wins; a remembered hex is kept only while the primary still is that color.
  def typed_hex(raw_primary, remembered, primary)
    hex = Themes::Oklch.normalize_hex(raw_primary) || Themes::Oklch.normalize_hex(remembered)
    hex if hex && Themes::Oklch.parse(hex) == primary
  end
end
