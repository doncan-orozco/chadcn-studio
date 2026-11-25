require "test_helper"
require "turbo/broadcastable/test_helper"

class Generations::Service::BroadcastTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "status replaces the generation status panel on the theme's stream" do
    generation = generations(:completed)
    streams = capture_turbo_stream_broadcasts(generation.theme) { Generations::Service::Broadcast.status(generation) }

    assert_equal 1, streams.size
    assert_equal "replace", streams.first["action"]
    assert_equal "generation_status", streams.first["target"]
  end

  test "status renders the panel alone, without the app layout" do
    generation = generations(:completed)
    stream = capture_turbo_stream_broadcasts(generation.theme) { Generations::Service::Broadcast.status(generation) }.first
    html = stream.at_css("template").inner_html

    assert_includes html, 'id="generation_status"'
    assert_no_match(/<(main|header|html|body|nav)\b/, html)
  end

  test "theme_changed sends the status and then a refresh" do
    generation = generations(:completed)
    streams = capture_turbo_stream_broadcasts(generation.theme) { Generations::Service::Broadcast.theme_changed(generation) }

    assert_equal %w[replace refresh], streams.map { |stream| stream["action"] }
  end
end
