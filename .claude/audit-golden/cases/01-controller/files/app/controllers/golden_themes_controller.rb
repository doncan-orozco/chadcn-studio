class GoldenThemesController < ApplicationController
  def publish
    @theme = Theme.find(params[:id])

    if @theme.archived?
      redirect_to themes_path, alert: "Cannot publish an archived theme"
      return
    end

    @theme.update!(status: :published)
    render html: view_context.tag.div(@theme.name)
  end
end
