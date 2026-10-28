class Themes::ExportsController < ApplicationController
  def show
    theme = Exports::Query::Published.call({ slug: params[:slug] }).take or return head :not_found
    export = Exports::Presenter.for(theme, format: params[:format], base_url: request.base_url) or return head :not_found

    send_data export.body, type: export.content_type, filename: export.filename, disposition: :attachment
  end
end
