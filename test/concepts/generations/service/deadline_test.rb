require "test_helper"

class Generations::Service::DeadlineTest < ActiveSupport::TestCase
  test "a fresh pending generation is not abandoned" do
    assert_not Generations::Service::Deadline.abandoned?(generations(:pending))
  end

  test "a pending generation past the deadline is abandoned" do
    later = generations(:pending).created_at + Generations::Service::Deadline::ABANDONED_AFTER + 1.minute

    assert Generations::Service::Deadline.abandoned?(generations(:pending), now: later)
  end

  test "a completed generation is never abandoned" do
    later = generations(:completed).created_at + 1.day

    assert_not Generations::Service::Deadline.abandoned?(generations(:completed), now: later)
  end
end
