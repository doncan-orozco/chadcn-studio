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
    result = @service.derive(values)
    report = Chadcn::Theme.validate(result.palette, strict: true)
    step Failure(code: :contrast, errors: report[:errors]) if report[:errors].any?

    { palette: result.palette, inputs: values, repairs: result.repairs, warnings: report[:warnings] }
  end

  private

  def validate(inputs)
    outcome = @contract.call(inputs.to_h)
    return Success(outcome.to_h) if outcome.success?

    Failure(code: :invalid, errors: outcome.errors.to_h)
  end
end
