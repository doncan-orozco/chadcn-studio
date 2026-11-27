# frozen_string_literal: true

# The generation panel of a theme's editor: where the prompt goes, which stream it listens to and the last generation, if any.
class Generations::Presenter::Panel < Core::Presenter::Base
  PROMPT_PARAM = "generation[prompt]"
  PROMPT_PLACEHOLDER = "warm editorial, terracotta, soft corners"

  def self.for(theme, configured: configured?)
    new(theme, latest: Generations::Query::Latest.call({ theme_id: theme.id }).first, configured: configured)
  end

  # A key in the environment, or the client the job was given (tests).
  def self.configured? = Generations::Service::Client.configured? || GenerateThemeJob.client.present?

  def initialize(theme, latest: nil, configured: self.class.configured?)
    super(theme)
    @latest = latest
    @configured = configured
  end

  def configured? = @configured

  def create_path = helpers.theme_generations_path(__getobj__)

  def stream_source = __getobj__

  # In the editor the way to the brand color is the Brand group's dialog.
  def brand_control = :dialog

  # The editor's field starts empty.
  def prompt = nil

  def prompt_param = PROMPT_PARAM

  def prompt_limit = Generations::Presenter::Status::PROMPT_LIMIT

  def prompt_placeholder = PROMPT_PLACEHOLDER

  # A studio that cannot generate says so instead of showing the last generation.
  def status
    return Generations::Presenter::Status.new(Generation.new, failure: :not_configured) unless @configured

    @latest && Generations::Presenter::Status.new(@latest)
  end
end
