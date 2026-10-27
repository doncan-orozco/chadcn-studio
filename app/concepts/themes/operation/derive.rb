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
    return Success(outcome.to_h) if outcome.success?

    Failure(code: :invalid, errors: outcome.errors.to_h)
  end
end
