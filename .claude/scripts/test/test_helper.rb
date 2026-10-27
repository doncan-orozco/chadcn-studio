# frozen_string_literal: true

# Tests of the repository tooling (.claude/scripts: the audit receipt and the epic board). They are not app tests and never boot
# Rails: `rake test:tooling` runs them, `bin/rails test` does not. ActiveSupport::TestCase gives them the `test "..." do` /
# `setup do` style they were written in.
require "pathname"
require "minitest/autorun"
require "active_support"
require "active_support/test_case"

TOOLING_ROOT = Pathname(File.expand_path("../../..", __dir__))
