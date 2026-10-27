require "test_helper"

class Core::OperationTest < ActiveSupport::TestCase
  class Sample < Core::Operation
    def call(model:, mode:)
      case mode
      when :ok then { model: model }
      when :model then fail_with_model!(inject_errors!(model, name: [ "is invalid" ]), code: :invalid)
      when :code then fail_with_code!(:refused, message: "declined")
      end
    end
  end

  Record = Struct.new(:errors)

  def record = Record.new(ActiveModel::Errors.new(Object.new))

  test "success returns the payload hash" do
    model = record

    assert_equal({ model: model }, Sample.new.call(model: model, mode: :ok).value!)
  end

  test "fail_with_model! injects the errors and carries the code" do
    model = record
    failure = Sample.new.call(model: model, mode: :model).failure

    assert_equal [ "is invalid" ], model.errors[:name]
    assert_equal({ model: model, errors: { name: [ "is invalid" ] }, code: :invalid }, failure)
  end

  test "fail_with_code! carries the code and message" do
    assert_equal({ code: :refused, message: "declined" }, Sample.new.call(model: nil, mode: :code).failure)
  end
end
