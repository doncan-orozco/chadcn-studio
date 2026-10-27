# Result Handling in Controllers

```ruby
def create
  result = Themes::Operation::Derive.new.call(model: theme, inputs: derivation_params.to_h)

  if result.success?
    @presenter = Themes::Presenter::Editor.new(result.value![:model])
    render turbo_stream: turbo_stream.replace("theme_editor", Components::Editor::Form.new(presenter: @presenter))
  else
    handle_failed_derivation(failure: result.failure)
  end
end

private

def handle_failed_derivation(failure:)
  case failure[:code]
  when :contrast
    @presenter = Themes::Presenter::Editor.new(failure[:model])
    render turbo_stream: turbo_stream.replace("theme_editor", Components::Editor::Form.new(presenter: @presenter)),
           status: :unprocessable_entity
  else
    redirect_to edit_theme_path(theme), alert: failure[:message] || "The theme could not be derived"
  end
end
```

Rules:
- `result.value!` only inside the success branch; `result.failure` only inside the else branch.
- Branch on the stable `failure[:code]`, never on model internals.
- An invalid model re-renders the same surface with `:unprocessable_entity`; it never redirects, so the user keeps their input.
- The failure hash carries `:model` when a form can re-render and `:message` when the user needs a sentence; the controller composes neither.
