class Themes::PublicationsController < ApplicationController
  def create
    result = Themes::Operation::Publish.new.call(model: theme)
    return render_dialog(result.value![:model]) if result.success? && from_export_dialog?

    respond_to_result result, notice: "Theme published"
  end

  def destroy
    result = Themes::Operation::Unpublish.new.call(model: theme)
    return render_dialog(result.value![:model]) if result.success? && from_export_dialog?

    respond_to_result result, notice: "Theme unpublished"
  end

  private

  def theme = @theme ||= Theme.find(params[:theme_id])

  def from_export_dialog? = request.format.turbo_stream? && params[:from] == Components::Editor::ExportDialog::Body::ORIGIN

  def respond_to_result(result, notice:)
    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: notice, status: :see_other
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end

  # Publishing or unpublishing from inside the Export dialog: the dialog comes back open on the new body (links or draft offer), the toggle and the header state follow.
  def render_dialog(model)
    sharing = Exports::Presenter::Sharing.new(model, base_url: request.base_url)
    compact = params[:trigger] == Components::Editor::ExportDialog::Body::TRIGGER_ROW
    render turbo_stream: [
      turbo_stream.replace(Components::Editor::ExportDialog.host_id(model.id), Components::Editor::ExportDialog.new(presenter: sharing, open: true, compact:)),
      turbo_stream.replace(Components::Editor::PublishToggle::FORM_ID, Components::Editor::PublishToggle.new(presenter: sharing)),
      turbo_stream.replace(Components::Editor::PublicationState::ID, Components::Editor::PublicationState.new(presenter: sharing))
    ]
  end
end
