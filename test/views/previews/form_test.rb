require "test_helper"

class Views::Previews::FormTest < ActiveSupport::TestCase
  test "the volume slider's thumb is named" do
    page = Capybara.string(Views::Previews::Form.new(Previews::Presenter::Form.new).call)

    assert page.has_css?("[role=slider][aria-label='Volume']")
  end
end
