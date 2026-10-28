# frozen_string_literal: true

# A labelled `Chadcn::Slider` wired to the preview controller: `value-change` while it moves (live preview, no request),
# `value-commit` on release (derivation request).
class Components::Editor::SliderField < Components::Base
  ACTIONS = {
    live: "chadcn--slider:value-change->editor--preview#slide chadcn--slider:value-commit->editor--preview#commit",
    commit: "chadcn--slider:value-commit->editor--preview#commit"
  }.freeze

  def initialize(id:, label:, value:, min:, max:, step:, channel: nil, live: true, name: nil)
    @id = id
    @label = label
    @slider = { default_value: [ value ], min: min, max: max, step: step, name: name }
    @channel = channel
    @live = live
  end

  def view_template
    div(class: "grid gap-2") do
      span(id: "#{@id}-label", class: "text-sm font-medium") { @label }
      render Chadcn::Slider.new(id: @id, aria: { labelledby: "#{@id}-label" }, data: data, **@slider)
    end
  end

  private

  def data
    wiring = { action: ACTIONS.fetch(@live ? :live : :commit), testid: @id }
    return wiring unless @channel

    wiring.merge(editor__preview_target: @channel, editor__preview_channel_param: @channel)
  end
end
