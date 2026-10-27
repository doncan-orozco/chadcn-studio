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
    return Success(report[:warnings]) if report[:errors].empty?

    Failure(code: :contrast, errors: report[:errors])
  end

  def validate(inputs)
    outcome = @contract.call(inputs.to_h)
    return Success(outcome.to_h) if outcome.success?

    Failure(code: :invalid, errors: outcome.errors.to_h)
  end
end
