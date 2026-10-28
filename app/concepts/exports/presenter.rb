# frozen_string_literal: true

# The export of a theme in a format the public URL serves.
module Exports::Presenter
  FORMATS = { "css" => Css, "json" => Json }.freeze

  # nil for a format that is not served or a stored palette `Chadcn::Theme` no longer accepts.
  def self.for(theme, format:, base_url:)
    klass = FORMATS[format.to_s] or return
    klass.new(theme, base_url: base_url) if Exports::Service::Servable.call(theme)
  end
end
