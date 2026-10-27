class PreviewsController < ApplicationController
  def show
    page = params[:page]
    return head :not_found unless Views::Previews::PAGES.include?(page)

    view = Views::Previews.const_get(page.camelize).new(Previews::Presenter.const_get(page.camelize).new)
    render Components::Previews::Root.new(page: view)
  end
end
