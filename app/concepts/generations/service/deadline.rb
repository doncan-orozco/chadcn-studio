# frozen_string_literal: true

# When a pending generation counts as lost (killed worker, failed enqueue) so it stops locking the theme.
module Generations::Service::Deadline
  # Worst legitimate run = 5 job attempts x (60 s timeout x 3 SDK tries) + polynomial waits ~= 23 min.
  ABANDONED_AFTER = 30.minutes

  def self.abandoned?(generation, now: Time.current)
    generation.pending? && generation.created_at < now - ABANDONED_AFTER
  end
end
