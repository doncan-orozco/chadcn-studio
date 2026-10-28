# frozen_string_literal: true

# The generation panel of a theme's editor: where the prompt goes, which stream it listens to and the last generation, if any.
class Generations::Presenter::Panel < Core::Presenter::Base
  def self.for(theme)
    new(theme, latest: Generations::Query::Latest.call({ theme_id: theme.id }).first)
  end

  def initialize(theme, latest: nil)
    super(theme)
    @latest = latest
  end

  def create_path = helpers.theme_generations_path(__getobj__)

  def stream_source = __getobj__

  def prompt_param = "generation[prompt]"

  def prompt_limit = Generations::Presenter::Status::PROMPT_LIMIT

  def prompt_placeholder = "warm editorial, terracotta, soft corners"

  def status = @latest && Generations::Presenter::Status.new(@latest)
end
