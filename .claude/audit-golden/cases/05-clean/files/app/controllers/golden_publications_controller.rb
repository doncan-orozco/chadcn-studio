class GoldenPublicationsController < ApplicationController
  def create
    result = Themes::Operation::Publish.new.call(model: theme)

    if result.success?
      redirect_to theme_path(theme), notice: "Theme published.", status: :see_other
    else
      render Views::Themes::Show.new(theme: result.failure[:model]), status: :unprocessable_entity
    end
  end

  private

  def theme
    @theme ||= Theme.find_by!(slug: params[:theme_slug])
  end
end
