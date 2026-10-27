# frozen_string_literal: true

class Views::Previews::Dashboard < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "space-y-6 p-6") do
      h1(class: "text-2xl font-semibold tracking-tight") { @presenter.title }
      stats
      div(class: "grid gap-6 lg:grid-cols-2") do
        traffic
        orders
      end
    end
  end

  private

  def stats
    div(class: "grid gap-4 sm:grid-cols-2 lg:grid-cols-4") do
      @presenter.stats.each do |stat|
        render Chadcn::Card.new(class: "gap-2") do |card|
          card.header { card.description { stat.label } }
          card.content do
            div(class: "text-2xl font-bold") { stat.value }
            p(class: "text-xs text-muted-foreground") { stat.change }
          end
        end
      end
    end
  end

  def traffic
    render Chadcn::Card.new do |card|
      card.header do
        card.title { "Traffic sources" }
        card.description { "Visitors by channel this month" }
      end
      card.content(class: "space-y-3") do
        @presenter.series.each do |series|
          div(class: "space-y-1") do
            span(class: "text-sm") { series.name }
            div(class: "h-3 rounded-full bg-muted") do
              div(class: "h-3 rounded-full #{@presenter.chart_class(series)}", style: @presenter.share_style(series))
            end
          end
        end
      end
    end
  end

  def orders
    render Chadcn::Card.new do |card|
      card.header do
        card.title { "Recent orders" }
        card.description { "Latest transactions" }
      end
      card.content do
        render Chadcn::Tabs.new(default_value: "all") do |tabs|
          tabs.list do
            tabs.trigger(value: "all") { "All" }
            tabs.trigger(value: "paid") { "Paid" }
          end
          tabs.content(value: "all") { table(@presenter.orders) }
          tabs.content(value: "paid") { table(@presenter.orders.select { |order| order.status == "Paid" }) }
        end
      end
    end
  end

  def table(orders)
    render Chadcn::Table.new do |t|
      t.header { t.row { %w[Customer Status Amount].each { |name| t.head { name } } } }
      t.body do
        orders.each do |order|
          t.row do
            t.cell do
              div(class: "font-medium") { order.customer }
              div(class: "text-xs text-muted-foreground") { order.email }
            end
            t.cell { render Chadcn::Badge.new(variant: @presenter.status_variant(order.status)) { order.status } }
            t.cell(class: "text-right") { order.amount }
          end
        end
      end
    end
  end
end
