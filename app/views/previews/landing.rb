# frozen_string_literal: true

class Views::Previews::Landing < Views::Base
  def initialize(presenter)
    @presenter = presenter
  end

  def view_template
    div(class: "space-y-16 p-6 pb-0") do
      hero
      features
      pricing
      footer_section
    end
  end

  private

  def hero
    section(class: "mx-auto max-w-2xl space-y-4 py-12 text-center") do
      render Chadcn::Badge.new(variant: "secondary") { "New: shareable themes" }
      h1(class: "text-4xl font-bold tracking-tight") { @presenter.headline }
      p(class: "text-lg text-muted-foreground") { @presenter.tagline }
      div(class: "flex justify-center gap-3") do
        render Chadcn::Button.new(size: "lg") { "Get started" }
        render Chadcn::Button.new(variant: "outline", size: "lg") { "Learn more" }
      end
    end
  end

  def features
    section(class: "mx-auto grid max-w-5xl gap-4 md:grid-cols-3") do
      @presenter.features.each do |feature|
        render Chadcn::Card.new(class: "bg-muted/40") do |card|
          card.header do
            card.title { feature.title }
            card.description { feature.description }
          end
        end
      end
    end
  end

  def pricing
    section(class: "mx-auto grid max-w-5xl gap-4 md:grid-cols-3") do
      @presenter.tiers.each do |tier|
        render Chadcn::Card.new(class: tier.featured ? "border-primary" : nil) do |card|
          card.header do
            card.title { tier.name }
            card.description { tier.blurb }
          end
          card.content(class: "space-y-3") do
            div(class: "text-3xl font-bold") { plain tier.price; span(class: "text-sm font-normal text-muted-foreground") { " /month" } }
            ul(class: "space-y-1 text-sm text-muted-foreground") { tier.perks.each { |perk| li { perk } } }
          end
          card.footer { render Chadcn::Button.new(variant: tier.featured ? "default" : "outline", class: "w-full") { "Choose #{tier.name}" } }
        end
      end
    end
  end

  def footer_section
    footer(class: "border-t py-8 text-center text-sm text-muted-foreground") { "Made with the chadcn design system." }
  end
end
