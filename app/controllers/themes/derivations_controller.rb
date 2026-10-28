class Themes::DerivationsController < ApplicationController
  def create
    result = Themes::Operation::Derive.new.call(inputs: derivation_inputs)

    if result.success?
      render Components::Editor::Derived.new(Themes::Presenter::Editor.derived(result.value!), controls: params[:controls].present?), **stream
    else
      render Components::Editor::Rejected.new(Themes::Presenter::Editor.new(Theme.new, failures: result.failure[:errors])), status: :unprocessable_entity, **stream
    end
  end

  private

  def stream = { layout: false, content_type: Mime[:turbo_stream] }

  # A cleared override field is posted blank: it is no override.
  def derivation_inputs
    inputs = params.expect(theme: [ inputs: [ :primary, :tint, :radius, { overrides: {} } ] ]).to_h.fetch("inputs")
    inputs.except("overrides").compact_blank.merge(overrides(inputs))
  end

  def overrides(inputs)
    pruned = inputs.fetch("overrides", {}).transform_values(&:compact_blank).compact_blank
    pruned.empty? ? {} : { "overrides" => pruned }
  end
end
