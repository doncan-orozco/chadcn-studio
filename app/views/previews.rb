# frozen_string_literal: true

# The preview pages: fixtures the theme is tried on (`design-system` R15). `PAGES` maps each `/previews/:page` to its
# [view class, presenter class]; it is also the allowlist of pages.
module Views::Previews
  PAGES = {
    "dashboard" => [ Dashboard, ::Previews::Presenter::Dashboard ].freeze,
    "form" => [ Form, ::Previews::Presenter::Form ].freeze,
    "landing" => [ Landing, ::Previews::Presenter::Landing ].freeze,
    "settings" => [ Settings, ::Previews::Presenter::Settings ].freeze,
    "auth" => [ Auth, ::Previews::Presenter::Auth ].freeze,
    "shell" => [ Shell, ::Previews::Presenter::Shell ].freeze
  }.freeze
end
