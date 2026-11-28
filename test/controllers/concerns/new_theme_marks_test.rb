require "test_helper"

class NewThemeMarksTest < ActiveSupport::TestCase
  class Host
    include NewThemeMarks

    attr_reader :session, :flash

    def initialize(session: {}, flash: {})
      @session = session
      @flash = flash
    end

    public :mark_landed, :fresh_theme_ids, :acknowledge_landing
  end

  test "marking a theme remembers it, flags the landing visit and keeps only the latest" do
    host = Host.new
    (1..(NewThemeMarks::CAP + 1)).each { |id| host.mark_landed(Struct.new(:id).new(id)) }

    assert_equal (2..(NewThemeMarks::CAP + 1)).to_a, host.fresh_theme_ids
    assert host.flash[:landed]
  end

  test "opening the editor clears the mark, except on the landing visit itself" do
    theme = Struct.new(:id).new(7)

    Host.new(session: { new_theme_ids: [ 7 ] }, flash: { landed: true }).tap { |host| host.acknowledge_landing(theme) }.then { |host| assert_equal [ 7 ], host.fresh_theme_ids }
    Host.new(session: { new_theme_ids: [ 7, 8 ] }).tap { |host| host.acknowledge_landing(theme) }.then { |host| assert_equal [ 8 ], host.fresh_theme_ids }
  end

  test "no marks reads as an empty list" do
    assert_empty Host.new.fresh_theme_ids
  end
end
