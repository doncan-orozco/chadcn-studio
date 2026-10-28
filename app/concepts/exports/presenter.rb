# frozen_string_literal: true

# The export of a theme in a format the public URL serves.
module Exports::Presenter
  FORMATS = { "css" => Css, "json" => Json }.freeze

  # nil for a format that is not served.
  def self.for(theme, format:, base_url:)
    FORMATS[format.to_s]&.new(theme, base_url: base_url)
  end
end
