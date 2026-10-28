class Themes::GenerationsController < ApplicationController
  def create
    result = Generations::Operation::Request.new.call(theme: Theme.find(params[:theme_id]), prompt: prompt)

    if result.success?
      render_status Generations::Presenter::Status.new(result.value![:model])
    else
      render_status Generations::Presenter::Status.new(result.failure[:model], failure: :prompt), status: :unprocessable_entity
    end
  end

  private

  def prompt = params.expect(generation: :prompt)[:prompt]

  def render_status(status, **options)
    render turbo_stream: turbo_stream.replace("generation_status", Components::Editor::GenerationStatus.new(status: status)), **options
  end
end
