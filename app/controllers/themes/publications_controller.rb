class Themes::PublicationsController < ApplicationController
  def create
    result = Themes::Operation::Publish.new.call(model: theme)

    redirect_to edit_theme_path(theme), **outcome(result, "Theme published", "Theme could not be published")
  end

  def destroy
    result = Themes::Operation::Unpublish.new.call(model: theme)

    redirect_to edit_theme_path(theme), **outcome(result, "Theme unpublished", "Theme could not be unpublished")
  end

  private

  def theme = @theme ||= Theme.find(params[:theme_id])

  def outcome(result, notice, alert)
    result.success? ? { notice: notice, status: :see_other } : { alert: alert, status: :see_other }
  end
end
