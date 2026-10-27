# frozen_string_literal: true

# Static sample data of the dashboard preview page: a fixture to show the theme on, never real figures.
class Previews::Presenter::Dashboard
  Stat = Data.define(:label, :value, :change)
  Series = Data.define(:name, :chart, :share)
  Order = Data.define(:customer, :email, :status, :amount)

  STATUS_VARIANTS = { "Paid" => "default", "Pending" => "secondary", "Refunded" => "outline", "Failed" => "destructive" }.freeze

  def title = "Dashboard"

  def stats
    [
      Stat.new("Total revenue", "$45,231.89", "+20.1% from last month"),
      Stat.new("Subscriptions", "+2,350", "+180.1% from last month"),
      Stat.new("Sales", "+12,234", "+19% from last month"),
      Stat.new("Active now", "+573", "+201 since last hour")
    ]
  end

  def series
    [
      Series.new("Direct", 1, 82), Series.new("Organic search", 2, 64), Series.new("Referral", 3, 47),
      Series.new("Social", 4, 31), Series.new("Email", 5, 18)
    ]
  end

  def orders
    [
      Order.new("Olivia Martin", "olivia.martin@example.com", "Paid", "$1,999.00"),
      Order.new("Jackson Lee", "jackson.lee@example.com", "Pending", "$39.00"),
      Order.new("Isabella Nguyen", "isabella.nguyen@example.com", "Paid", "$299.00"),
      Order.new("William Kim", "will@example.com", "Refunded", "$99.00"),
      Order.new("Sofia Davis", "sofia.davis@example.com", "Failed", "$39.00")
    ]
  end

  def status_variant(status) = STATUS_VARIANTS.fetch(status)
  CHART_CLASSES = { 1 => "bg-chart-1", 2 => "bg-chart-2", 3 => "bg-chart-3", 4 => "bg-chart-4", 5 => "bg-chart-5" }.freeze

  def chart_class(series) = CHART_CLASSES.fetch(series.chart)
  def share_style(series) = "width: #{series.share}%"
end
