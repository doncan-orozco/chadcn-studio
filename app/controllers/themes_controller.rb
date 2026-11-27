class ThemesController < ApplicationController
  def index
    render Views::Themes::Index.new(Themes::Presenter::List.new(Themes::Query::Recent.call), deleted: flash[:deleted])
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
    render Views::Themes::Edit.new(Themes::Presenter::Editor.new(theme))
  end

  def update
    before = { name: theme.name, inputs: theme.inputs.to_h.deep_dup }
    result = Themes::Operation::Update.new.call(model: theme, params: update_params.to_h)

    if result.success?
      saved = result.value![:model]
      redirect_to edit_theme_path(saved), notice: saved_notice(saved, before)
    else
      render Views::Themes::Edit.new(Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
    end
  end

  def destroy
    result = Themes::Operation::Destroy.new.call(model: theme)

    if result.success?
      # The toast says it for a moment; `deleted` is the lasting line the list keeps showing (the layout keeps it out of the toaster).
      flash[:deleted] = "#{result.value![:model].name} deleted"
      redirect_to themes_path, notice: "Theme deleted", status: :see_other
    else
      redirect_to theme_path(result.failure[:model]), alert: "Theme could not be deleted", status: :see_other
    end
  end

  private

  def theme = @theme ||= Theme.find(params[:id])

  MAX_NAMED_CHANGES = 3
  private_constant :MAX_NAMED_CHANGES

  # "Ocean saved: primary changed, border pinned": what this save changed, not only whose theme it was.
  def saved_notice(saved, before)
    changes = changes_since(saved, before)
    return "#{saved.name} saved" if changes.empty?

    named = changes.first(MAX_NAMED_CHANGES)
    named << "#{changes.size - MAX_NAMED_CHANGES} more" if changes.size > MAX_NAMED_CHANGES
    "#{saved.name} saved: #{named.join(', ')}"
  end

  def changes_since(saved, before)
    changes = []
    changes << "renamed from #{before[:name]}" if saved.name != before[:name]
    %w[primary tint radius].each do |key|
      changes << "#{key} changed" if saved.inputs[key] != before[:inputs][key]
    end
    changes + override_changes(before[:inputs]["overrides"].to_h, saved.inputs["overrides"].to_h)
  end

  def override_changes(was, now)
    pins = ->(overrides) { overrides.flat_map { |mode, variables| variables.to_h.map { |name, value| [ [ mode, name ], value ] } }.to_h }
    old_pins = pins.call(was)
    new_pins = pins.call(now)
    pinned = new_pins.select { |key, value| old_pins[key] != value }.keys.map(&:last)
    unpinned = (old_pins.keys - new_pins.keys).map(&:last)
    pinned.uniq.map { |name| "#{name} pinned" } + (unpinned - pinned).uniq.map { |name| "#{name} unpinned" }
  end

  def create_params = params.expect(theme: %i[name primary]).to_h.symbolize_keys.slice(:name, :primary)

  def update_params = params.expect(theme: [ :name, { inputs: [ :primary, :tint, :radius, { overrides: {} } ] } ])
end
