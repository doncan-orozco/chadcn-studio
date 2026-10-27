# frozen_string_literal: true

# One labelled share bar of the dashboard's traffic card, filled with a chart token.
class Components::Previews::TrafficBar < Components::Base
  # Literal classes so Tailwind sees them.
  FILLS = { 1 => "bg-chart-1", 2 => "bg-chart-2", 3 => "bg-chart-3", 4 => "bg-chart-4", 5 => "bg-chart-5" }.freeze

  def initialize(name:, share:, index:, **attrs)
    @name = name
    @share = Integer(share).clamp(0, 100)
    @index = index
    @attrs = attrs
  end

  def view_template
    div(**mix({ class: "space-y-1" }, @attrs)) do
      div(class: "flex items-center justify-between text-sm") do
        span { @name }
        span(class: "text-muted-foreground") { "#{@share}%" }
      end
      div(class: "h-3 rounded-full bg-muted", role: "meter", aria: { label: @name, valuenow: @share, valuemin: 0, valuemax: 100, valuetext: "#{@share}%" }) do
        div(class: "h-3 rounded-full #{FILLS.fetch(@index)}", style: "width: #{@share}%")
      end
    end
  end
end
