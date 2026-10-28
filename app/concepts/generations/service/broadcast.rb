# frozen_string_literal: true

# What the editor is told over Turbo Streams: the status panel, and a refresh of the page once the theme changed.
module Generations::Service::Broadcast
  def self.status(generation)
    Turbo::StreamsChannel.broadcast_replace_to(
      generation.theme, target: "generation_status",
      renderable: Components::Editor::GenerationStatus.new(status: Generations::Presenter::Status.new(generation))
    )
  end

  def self.theme_changed(generation)
    status(generation)
    Turbo::StreamsChannel.broadcast_refresh_to(generation.theme)
  end
end
