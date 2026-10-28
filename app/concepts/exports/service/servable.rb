# frozen_string_literal: true

# Whether a stored palette may go out on the public URL: `Chadcn::Theme` judges it again at serve time, so a gem bump
# that adds a required variable stops serving older themes instead of exporting them incomplete (theme-science R12).
class Exports::Service::Servable
  def self.call(theme)
    errors = Chadcn::Theme.validate(theme.palette)[:errors]
    return true if errors.empty?

    Rails.logger.warn("[exports] theme #{theme.slug} not served: #{errors.join('; ')}")
    false
  end
end
