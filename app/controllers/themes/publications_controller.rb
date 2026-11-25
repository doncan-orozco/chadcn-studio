class Themes::PublicationsController < ApplicationController
  def create
    result = Themes::Operation::Publish.new.call(model: theme)
    return render_dialog(result.value![:model]) if result.success? && from_export_dialog?

    respond_to_result result, notice: "Theme published"
  end

  def destroy
    respond_to_result Themes::Operation::Unpublish.new.call(model: theme), notice: "Theme unpublished"
  end

  private

  def theme = @theme ||= Theme.find(params[:theme_id])

  def from_export_dialog? = request.format.turbo_stream? && params[:from] == "export_dialog"

  def respond_to_result(result, notice:)
    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: notice, status: :see_other
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end

  # Publishing from inside the Export dialog: swap the dialog body and the toggle, the dialog stays open.
  def render_dialog(model)
    sharing = Exports::Presenter::Sharing.new(model, base_url: request.base_url)
    render turbo_stream: [
      turbo_stream.replace("export-body", Components::Editor::ExportDialog::Body.new(presenter: sharing)),
      turbo_stream.replace("publish-toggle-form", Components::Editor::PublishToggle.new(presenter: sharing))
    ]
  end
end
