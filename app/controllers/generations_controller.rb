class GenerationsController < ApplicationController
  FAILURES = %i[busy capped not_configured].freeze
  private_constant :FAILURES

  rate_limit to: 5, within: 1.minute, only: :create, with: -> { throttled }

  def create
    result = Generations::Operation::Begin.new.call(prompt: prompt, configured: Generations::Presenter::Panel.configured?, hourly_cap: hourly_cap)

    if result.success?
      landed(result.value![:model])
    else
      code = result.failure[:code]
      failure = FAILURES.include?(code) ? code : :prompt
      render_new Generations::Presenter::Status.new(result.failure[:model], failure: failure), status: :unprocessable_entity
    end
  end

  private

  # The editor opens on the theme just made: the toast names it, and the list marks its card New until the editor is opened again
  # (`landed` tells the editor this visit is the landing, not that second opening).
  def landed(theme)
    session[:new_theme_ids] = (Array(session[:new_theme_ids]) | [ theme.id ]).last(20)
    flash[:landed] = true
    redirect_to edit_theme_path(theme), notice: "Created #{theme.name} from your description"
  end

  def throttled = render_new(Generations::Presenter::Status.new(Generation.new, failure: :throttled), status: :too_many_requests)

  def hourly_cap = Rails.configuration.x.generations.hourly_cap

  def prompt = params.expect(generation: :prompt)[:prompt]

  def render_new(status, **options)
    render Views::Themes::New.new(Theme.new, intake: Generations::Presenter::Intake.for(prompt: prompt, status: status)), **options
  end
end
