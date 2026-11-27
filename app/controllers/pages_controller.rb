class PagesController < ApplicationController
  HOME_THEMES = 5

  def home
    render Views::Pages::Home.new(Themes::Presenter::List.new(Themes::Query::Recent.call.limit(HOME_THEMES), base_url: request.base_url))
  end
end
