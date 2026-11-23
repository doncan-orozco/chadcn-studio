class PagesController < ApplicationController
  def home
    render Views::Pages::Home.new(Themes::Presenter::List.new(Themes::Query::Recent.call.limit(5)))
  end
end
