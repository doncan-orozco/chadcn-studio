class Themes::PublicationsController < ApplicationController
  def create
    respond_to_result Themes::Operation::Publish.new.call(model: theme), notice: "Theme published"
  end

  def destroy
    respond_to_result Themes::Operation::Unpublish.new.call(model: theme), notice: "Theme unpublished"
  end

  private

  def theme = @theme ||= Theme.find(params[:theme_id])

  def respond_to_result(result, notice:)
    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: notice, status: :see_other
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end
end
