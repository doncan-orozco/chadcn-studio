require "test_helper"

class Views::Pages::HomeTest < ActionDispatch::IntegrationTest
  test "a theme row link is at least 32 px tall" do
    get root_path

    assert_select "ul[aria-label='Your themes'] li > a.min-h-8"
  end
end
