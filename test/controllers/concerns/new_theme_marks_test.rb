require "test_helper"

class NewThemeMarksTest < ActiveSupport::TestCase
  class Host
    include NewThemeMarks

    attr_reader :session, :request

    def initialize(session: {}, headers: {})
      @session = session
      @request = Struct.new(:headers).new(headers)
    end

    public :mark_landed, :fresh_theme_ids, :leave_landing, :acknowledge_landing
  end

  Theme = Struct.new(:id)

  test "marking a theme remembers it, starts its landing and keeps only the latest" do
    host = Host.new
    (1..(NewThemeMarks::CAP + 1)).each { |id| host.mark_landed(Theme.new(id)) }

    assert_equal (2..(NewThemeMarks::CAP + 1)).to_a, host.fresh_theme_ids
    assert_equal NewThemeMarks::CAP + 1, host.session[:landing_theme_id]
  end

  test "the mark is kept during the landing and cleared on the first opening after the list" do
    host = Host.new(session: { new_theme_ids: [ 7, 8 ], landing_theme_id: 7 })

    host.acknowledge_landing(Theme.new(7))

    assert_equal [ 7, 8 ], host.fresh_theme_ids

    host.leave_landing
    host.acknowledge_landing(Theme.new(7))

    assert_equal [ 8 ], host.fresh_theme_ids
  end

  test "a prefetch never clears the mark" do
    host = Host.new(session: { new_theme_ids: [ 7 ] }, headers: { "X-Sec-Purpose" => "prefetch" })

    host.acknowledge_landing(Theme.new(7))

    assert_equal [ 7 ], host.fresh_theme_ids
  end

  test "no marks reads as an empty list and writes nothing to the session" do
    host = Host.new

    assert_empty host.fresh_theme_ids

    host.acknowledge_landing(Theme.new(7))

    assert_empty host.session
  end
end
