# frozen_string_literal: true

# The generation form of the New theme page: a prompt for a theme that does not exist yet. It answers what the editor's
# `Generations::Presenter::Panel` answers, so `Components::Editor::GenerationPanel` renders either one.
class Generations::Presenter::Intake < Core::Presenter::Base
  # `status` is a refused prompt's explanation (a `Generations::Presenter::Status`), nil on a first visit.
  def self.for(prompt: nil, status: nil, configured: Generations::Presenter::Panel.configured?)
    new(Generation.new(prompt: prompt), status: status, configured: configured)
  end

  def initialize(generation, status:, configured:)
    super(generation)
    @status = status
    @configured = configured
  end

  def configured? = @configured

  def title
    "Or describe it" if configured?
  end

  def description
    "Claude picks the colors from your words. You can adjust them in the editor." if configured?
  end

  def create_path = helpers.generations_path

  # No theme to listen to yet: the editor takes over once the theme exists.
  def stream_source = nil

  # On New theme the way to the brand color is the Brand color field.
  def brand_control = :field

  def prompt_param = Generations::Presenter::Panel::PROMPT_PARAM

  def prompt_limit = Generations::Presenter::Status::PROMPT_LIMIT

  def prompt_placeholder = Generations::Presenter::Panel::PROMPT_PLACEHOLDER

  def status
    return Generations::Presenter::Status.new(Generation.new, failure: :not_configured) unless @configured

    @status
  end
end
