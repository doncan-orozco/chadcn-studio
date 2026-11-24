# frozen_string_literal: true

# A labelled `Chadcn::Slider` wired to the preview controller: `value-change` while it moves (live preview, no request),
# `value-commit` on release (derivation request).
class Components::Editor::SliderField < Components::Base
  ACTIONS = {
    live: "chadcn--slider:value-change->editor--preview#slide chadcn--slider:value-commit->editor--preview#commit",
    commit: "chadcn--slider:value-commit->editor--preview#commit"
  }.freeze
  MIRROR = "chadcn--slider:value-change->editor--slider-number#mirror"

  def initialize(id:, label:, value:, min:, max:, step:, channel: nil, live: true, name: nil, unit: nil)
    @id = id
    @label = label
    @slider = { default_value: [ value ], min: min, max: max, step: step, name: name }
    @channel = channel
    @live = live
    @unit = unit
    @value = value
    @range = { min: min, max: max, step: step }
  end

  def view_template
    return field unless @unit

    div(class: "grid gap-2", data: { controller: "editor--slider-number", editor__slider_number_unit_value: @unit }) { field }
  end

  private

  def field
    div(class: "grid gap-2") do
      label_text
      div(class: "flex items-center gap-3") do
        render Chadcn::Slider.new(id: @id, aria: { labelledby: "#{@id}-label" }, data: data, **@slider)
        number_box if @unit
      end
    end
  end

  def label_text
    span(id: "#{@id}-label", class: "text-sm font-medium") do
      plain "#{@label} "
      next unless @unit

      output(for: "#{@id}-number", data: { editor__slider_number_target: "readout", testid: "#{@id}-value" }) { "#{@value}#{@unit}" }
    end
  end

  # Kept out of the editor form (`form:` names no form): a stored radius off the box's step grid (0.625rem) would fail the
  # browser's step validation and block Save. The slider and the hidden `radiusField` carry the value that is posted.
  def number_box
    render Chadcn::Input.new(
      id: "#{@id}-number", type: "number", default_value: @value, class: "w-20 shrink-0", form: "#{@id}-number-form", aria: { label: "#{@label} in #{@unit}" },
      data: { editor__slider_number_target: "input", action: "change->editor--slider-number#type keydown.enter->editor--slider-number#confirm", testid: "#{@id}-number" }, **@range
    )
  end

  def data
    wiring = { editor__slider_number_target: ("slider" if @unit), action: [ ACTIONS.fetch(@live ? :live : :commit), (MIRROR if @unit) ].compact.join(" "), testid: @id }
    return wiring unless @channel

    wiring.merge(editor__preview_target: @channel, editor__preview_channel_param: @channel)
  end
end
