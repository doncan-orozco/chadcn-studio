# frozen_string_literal: true

# A labelled `Chadcn::Slider` wired to the preview controller: `value-change` while it moves (live preview, no request),
# `value-commit` on release (derivation request).
class Components::Editor::SliderField < Components::Base
  # How a thumb says its value: the slider value times `scale`, rounded to `digits`, followed by `unit` (0.488 as "48.8%").
  Speech = Data.define(:scale, :digits, :unit) do
    def initialize(scale: 1, digits: 0, unit: "") = super

    def data
      { controller: "editor--slider-speech", editor__slider_speech_scale_value: scale, editor__slider_speech_digits_value: digits, editor__slider_speech_unit_value: unit }
    end
  end
  ACTIONS = {
    live: "chadcn--slider:value-change->editor--preview#slide chadcn--slider:value-commit->editor--preview#commit",
    commit: "chadcn--slider:value-commit->editor--preview#commit"
  }.freeze
  MIRROR = "chadcn--slider:value-change->editor--slider-number#mirror"
  SPEAK = "chadcn--slider:value-change->editor--slider-speech#mirror"
  DETACHED_FORM_SUFFIX = "-number-form"

  def initialize(id:, label:, value:, min:, max:, step:, channel: nil, live: true, name: nil, unit: nil, speak: nil)
    raise ArgumentError, "speak: and unit: are exclusive (a unit already speaks its value)" if speak && unit

    @id = id
    @label = label
    @channel = channel
    @live = live
    @unit = unit
    @speak = speak
    @value = value.is_a?(Float) && value == value.floor ? value.to_i : value
    @range = { min: min, max: max, step: step }
    @slider = { default_value: [ @value ], name: name, **@range }
  end

  def view_template
    return div(class: "grid gap-2", data: @speak.data) { field } if @speak
    return field unless @unit

    div(class: "grid gap-2", data: { controller: "editor--slider-number", editor__slider_number_unit_value: @unit }) { field }
  end

  private

  def field
    div(class: "grid gap-2") do
      label_text
      div(class: "flex items-center gap-3") do
        render Chadcn::Slider.new(id: @id, label: @label, thumb_class: Components::Editor::HitArea::THUMB, aria: { labelledby: "#{@id}-label" }, data: slider_attributes, **@slider)
        number_box if @unit
      end
    end
  end

  def label_text
    div(class: "flex items-baseline gap-1 text-sm font-medium") do
      span(id: "#{@id}-label") { @label }
      next unless @unit

      output(for: "#{@id}-number", aria: { live: "off" }, data: { editor__slider_number_target: "readout", testid: "#{@id}-value" }) { "#{@value}#{@unit}" }
    end
  end

  # Kept out of the editor form (`form:` names no form): a stored radius off the box's step grid (0.625rem) would fail the
  # browser's step validation and block Save. The slider and the hidden `radiusField` carry the value that is posted.
  def number_box
    render Chadcn::Input.new(
      id: "#{@id}-number", type: "number", default_value: @value, class: "w-20 shrink-0", form: "#{@id}#{DETACHED_FORM_SUFFIX}", aria: { label: "#{@label} in #{@unit}" },
      data: { editor__slider_number_target: "input", action: "change->editor--slider-number#type", testid: "#{@id}-number" }, **@range
    )
  end

  def slider_attributes
    attributes = { editor__slider_number_target: ("slider" if @unit), editor__slider_speech_target: ("slider" if @speak), testid: @id,
                   action: [ ACTIONS.fetch(@live ? :live : :commit), (MIRROR if @unit), (SPEAK if @speak) ].compact.join(" ") }
    return attributes unless @channel

    attributes.merge(editor__preview_target: @channel, editor__preview_channel_param: @channel)
  end
end
