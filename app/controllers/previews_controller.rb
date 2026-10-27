class PreviewsController < ApplicationController
  def show
    view_class, presenter_class = Views::Previews::PAGES.fetch(params[:page]) { return head :not_found }

    render Components::Previews::Root.new(page: view_class.new(presenter_class.new))
  end
end
