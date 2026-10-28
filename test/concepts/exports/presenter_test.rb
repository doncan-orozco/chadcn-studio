require "test_helper"

class Exports::PresenterTest < ActiveSupport::TestCase
  test "picks the presenter of a served format" do
    assert_instance_of Exports::Presenter::Css, Exports::Presenter.for(themes(:slate), format: "css", base_url: "https://studio.test")
    assert_instance_of Exports::Presenter::Json, Exports::Presenter.for(themes(:slate), format: "json", base_url: "https://studio.test")
  end

  test "any other format is nil" do
    assert_nil Exports::Presenter.for(themes(:slate), format: "xml", base_url: "https://studio.test")
    assert_nil Exports::Presenter.for(themes(:slate), format: nil, base_url: "https://studio.test")
  end
end
