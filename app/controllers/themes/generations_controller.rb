class Themes::GenerationsController < ApplicationController
  FAILURES = %i[busy capped].freeze
  private_constant :FAILURES

  rate_limit to: 5, within: 1.minute, only: :create, with: -> { throttled }

  def create
    result = Generations::Operation::Request.new.call(theme: Theme.find(params[:theme_id]), prompt: prompt, hourly_cap: hourly_cap)

    if result.success?
      render_status Generations::Presenter::Status.new(result.value![:model])
    else
      code = result.failure[:code]
      failure = FAILURES.include?(code) ? code : :prompt
      render_status Generations::Presenter::Status.new(result.failure[:model], failure: failure), status: :unprocessable_entity
    end
  end

  private

  def throttled
    render_status Generations::Presenter::Status.new(Generation.new, failure: :throttled), status: :too_many_requests
  end

  def hourly_cap = Rails.configuration.x.generations.hourly_cap

  def prompt = params.expect(generation: :prompt)[:prompt]

  def render_status(status, **options)
    render turbo_stream: turbo_stream.replace("generation_status", Components::Editor::GenerationStatus.new(status: status)), **options
  end
end
