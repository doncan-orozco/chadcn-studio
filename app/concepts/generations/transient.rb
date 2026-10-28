# frozen_string_literal: true

# A failure worth trying again (rate limit, connection, timeout): the client raises it, the job retries it.
class Generations::Transient < StandardError; end
