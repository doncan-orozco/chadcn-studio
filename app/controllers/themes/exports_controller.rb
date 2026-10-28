class Themes::ExportsController < ApplicationController
  def show
    theme = Exports::Query::Published.call(params[:slug]) or return head :not_found
    export = presenter(theme) or return head :not_found

    send_data export.body, type: export.content_type, filename: export.filename, disposition: :attachment
  end

  private

  def presenter(theme)
    case params[:format]
    when "css" then Exports::Presenter::Css.new(theme, url: theme_export_url(theme.slug, format: "css"))
    when "json" then Exports::Presenter::Json.new(theme)
    end
  end
end
