# frozen_string_literal: true

# A theme as JSON: its name, slug, the inputs it was derived from and the palette in both modes.
class Exports::Presenter::Json < Core::Presenter::Base
  CONTENT_TYPE = "application/json"

  def body
    JSON.pretty_generate(name: name, slug: slug, inputs: inputs, light: light, dark: dark) + "\n"
  end

  def filename = "#{slug}.json"
  def content_type = CONTENT_TYPE
end
