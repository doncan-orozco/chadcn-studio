class Themes::ExportsController < ApplicationController
  def show
    theme = export_query.call({ slug: params[:slug] }).take or return head :not_found
    export = Exports::Presenter.for(theme, format: params[:format], base_url: request.base_url) or return head :not_found

    send_data export.body, type: export.content_type, filename: export.filename, disposition: :attachment
  end

  private

  # The public URL serves published themes; the studio's own download (`?draft=1`, from a draft's Export dialog) reaches a draft too.
  def export_query = params[:draft] == "1" ? Exports::Query::Downloadable : Exports::Query::Published
end
