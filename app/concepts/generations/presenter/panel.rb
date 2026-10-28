# frozen_string_literal: true

# The generation panel of a theme's editor: where the prompt goes, which stream it listens to and the last generation, if any.
class Generations::Presenter::Panel < Core::Presenter::Base
  def create_path = helpers.theme_generations_path(__getobj__)

  def stream_source = __getobj__

  def status
    latest = generations.order(:id).last
    latest && Generations::Presenter::Status.new(latest)
  end
end
