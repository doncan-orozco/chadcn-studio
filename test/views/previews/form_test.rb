require "test_helper"

class Views::Previews::FormTest < ActiveSupport::TestCase
  test "the volume slider's thumb is named" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_css?("[role=slider][aria-label='Volume']")
  end

  test "a caption under the email field says its error is a sample, and the input is described by it" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_css?("#form-email-sample", text: "Sample validation state")
    assert_equal "form-email-sample form-email-error", page.find_by_id("form-email")["aria-describedby"]
  end

  test "the primary action and a checked control come before the long fields" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_xpath?("//button[normalize-space()='Create account'][following::*[@id='form-bio']]")
    assert page.has_xpath?("//*[@id='form-terms'][following::*[@id='form-bio']]")
    assert page.has_css?("#form-terms[role=checkbox][aria-checked=true]")
  end
end
