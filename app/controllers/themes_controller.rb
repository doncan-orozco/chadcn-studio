class ThemesController < ApplicationController
  def index
    render Views::Themes::Index.new(Themes::Presenter::List.new(Themes::Query::Recent.call))
  end

  def show
    render Views::Themes::Show.new(Themes::Presenter::Show.new(theme))
  end

  def new
    render Views::Themes::New.new(Theme.new)
  end

  def create
    result = Themes::Operation::Create.new.call(**create_params)

    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: "Theme created"
    else
      render Views::Themes::New.new(result.failure[:model]), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Themes::Edit.new(Themes::Presenter::Editor.new(theme))
  end

  def update
    result = Themes::Operation::Update.new.call(model: theme, params: update_params.to_h)

    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: "Theme saved"
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end

  def destroy
    Themes::Operation::Destroy.new.call(model: theme)

    redirect_to themes_path, notice: "Theme deleted", status: :see_other
  end

  private

  def theme = Theme.find(params[:id])

  def create_params = params.expect(theme: %i[name primary]).to_h.symbolize_keys

  def update_params = params.expect(theme: [ :name, { inputs: %i[primary tint radius] } ])
end
