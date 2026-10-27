class GalleryController < ApplicationController
  def show
    render Views::Gallery::Show.new(Gallery::Presenter::Index.new)
  end
end
