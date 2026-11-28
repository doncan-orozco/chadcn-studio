class ThemesController < ApplicationController
  include NewThemeMarks

  before_action :leave_landing, only: %i[index show new]

  def index
    render Views::Themes::Index.new(Themes::Presenter::List.new(Themes::Query::Recent.call, base_url: request.base_url, fresh_ids: fresh_theme_ids), deleted: flash[:deleted])
  end

  def show
    render Views::Themes::Show.new(Themes::Presenter::Show.new(theme))
  end

  def new
    render Views::Themes::New.new(Theme.new, intake: Generations::Presenter::Intake.for)
  end

  def create
    result = Themes::Operation::Create.new.call(**create_params)

    if result.success?
      redirect_to edit_theme_path(result.value![:model]), notice: "Theme created"
    else
      render Views::Themes::New.new(result.failure[:model], intake: Generations::Presenter::Intake.for), status: :unprocessable_entity
    end
  end

  def edit
    acknowledge_landing(theme)
    render Views::Themes::Edit.new(Themes::Presenter::Editor.new(theme))
  end

  def update
    result = Themes::Operation::Update.new.call(model: theme, params: update_params.to_h)

    if result.success?
      payload = result.value!
      redirect_to edit_theme_path(payload[:model]), notice: Themes::Presenter::SavedNotice.new(payload[:model], changes: payload[:changes]).to_s
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end

  def destroy
    result = Themes::Operation::Destroy.new.call(model: theme)

    if result.success?
      # One message, in the theme's own words: `deleted` is the lasting line the list shows (the layout keeps it out of the toaster), so there is no toast beside it.
      flash[:deleted] = "#{result.value![:model].name} deleted"
      redirect_to themes_path, status: :see_other
    else
      redirect_to theme_path(result.failure[:model]), alert: "Theme could not be deleted", status: :see_other
    end
  end

  private

  def theme = @theme ||= Theme.find(params[:id])

  def create_params = params.expect(theme: %i[name primary]).to_h.symbolize_keys.slice(:name, :primary)

  def update_params = params.expect(theme: [ :name, { inputs: [ :primary, :tint, :radius, { overrides: {} } ] } ])
end
