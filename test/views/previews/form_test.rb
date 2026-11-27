require "test_helper"

class Views::Previews::FormTest < ActiveSupport::TestCase
  test "the volume slider's thumb is named" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_css?("[role=slider][aria-label='Volume']")
  end

  test "a caption under the email field says its error is a sample, and the input is described by it" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_css?("#form-email-sample", text: "Sample validation state")
    assert_equal "form-email-sample form-email-error", page.find("#form-email")["aria-describedby"]
  end
end
