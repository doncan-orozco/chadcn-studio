# frozen_string_literal: true

class Core::Operation < Dry::Operation
  include Dry::Monads[:result]

  private

  def model_errors(model) = model.errors.messages

  # Injects a hash of errors (from a contract) into an ActiveModel instance.
  def inject_errors!(model, errors_hash)
    errors_hash.each do |field, messages|
      Array(messages).each { |message| model.errors.add(field, message) }
    end

    model
  end

  # Halts the operation: `call` returns the Failure.
  def fail_with_model!(model, code: nil)
    failure = { model: model, errors: model_errors(model) }
    failure[:code] = code if code

    step Failure(failure)
  end

  def fail_with_code!(code, message: nil)
    failure = { code: code }
    failure[:message] = message if message

    step Failure(failure)
  end
end
