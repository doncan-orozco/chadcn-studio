require "application_system_test_case"

# Keeps the system suite runnable (CI's system-test job loads test/system) until the first real page exists.
class HealthTest < ApplicationSystemTestCase
  test "the health endpoint answers in the browser" do
    visit rails_health_check_path

    assert_equal 200, page.status_code
  end
end
