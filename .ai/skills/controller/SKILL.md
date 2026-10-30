---
name: controller
description: "Golden archetype for Rails controllers in chadcn-studio. Use when creating, editing, reviewing or refactoring any file in `app/controllers/` or `config/routes.rb`, or when handling operation results, Turbo Stream responses, or RESTful extraction of custom actions. Single source of truth for controller guidance."
---

# Golden Controller Skill (chadcn-studio)

Controllers are the **HTTP boundary only**: parse params, dispatch one Query (read) or Operation (write), then redirect/render. They are NOT for queries, business logic, display logic, color math or HTML generation. For workflows in `app/concepts/*/operation/` pair with `../operation-pattern/SKILL.md`.

## Applies to
- when: `app/controllers/**/*.rb`
- when: `config/routes.rb`
- system-review: when-touched
- note: `config/routes.rb` has no methods or classes; the orchestrator sends it straight to the system-level review.

## Quick Rules

Cite as `controller R<n>`. Detail and examples follow below / in references/.

R1. **Strict REST.** Only `index show new create edit update destroy`; no custom verbs (`derive`, `generate`, `export`). Transitions are sub-resource controllers (`Themes::DerivationsController#create`, `Themes::GenerationsController#create`, `Themes::ExportsController#show`). → detail: Routes
R2. **No business logic or state guard clauses.** Never check `@theme.complete?` etc. in the controller; the Operation validates state and returns a failure.
R3. **No view helpers in controllers.** No tab parsing, URL builders or badge logic; pass raw `params` to the Phlex view. Build a presenter once, assign `@presenter` once, and reuse it for layout and view.
R4. **Lean base controller.** `ApplicationController` holds only `layout`, `rescue_from` and `include`; feature logic goes in `app/controllers/concerns/`.
R5. **Find once, pass `model:`.** Find the record once in the controller and pass `model:` to the Operation; no second lookup inside the operation.
R6. **Handle both result branches.** `result.value!` only in the success branch, `result.failure` only in the else; never `result[:model]`. Invalid model ⇒ `render … status: :unprocessable_entity`, never redirect. → detail: references/result-handling.md
R7. **One operation per action.** One user action dispatches ONE Operation; route outcomes on `failure[:code]`, do not chain sibling operations in the controller. → detail: references/result-handling.md
R8. **No HTML generation.** No `view_context.tag` or inline markup, including Turbo Streams. Render a Phlex component or dedicated template. → detail: Turbo Streams
R9. **Previews are read-only routes.** `PreviewsController#show` takes `params[:page]` from an allowlist (`Views::Previews::PAGES`) and renders the preview with the current theme's variables; it never mutates.
R10. **Exports set the content type.** `Themes::ExportsController#show` responds to `.css` and `.json` formats with `render plain:`/`render json:` of the presenter's output and `Content-Disposition` for the download; the public URL used by `chadcn:theme:import` is this action with `.css`.
R11. **Generation is asynchronous.** `Themes::GenerationsController#create` enqueues the job through the operation and responds with a Turbo Stream that renders the pending state; it never calls the LLM inline. → `llm-generation` R6

## Minimal shape

```ruby
def update
  result = Themes::Operation::Update.new.call(model: theme, params: theme_params.to_h)

  if result.success?
    redirect_to edit_theme_path(result.value![:model]), notice: "Theme saved"
  else
    render Views::Themes::Edit.new(presenter: Themes::Presenter::Editor.new(result.failure[:model])), status: :unprocessable_entity
  end
end
```

## Routes

```ruby
resources :themes, only: %i[index show new create edit update destroy] do
  resource :derivation, only: :create, module: :themes
  resource :generation, only: :create, module: :themes
  resource :export, only: :show, module: :themes
end
resources :previews, only: :show, param: :page
get "/gallery", to: "gallery#show"
```

## Turbo Streams

A stream response renders a Phlex component: `render turbo_stream: turbo_stream.replace("theme_editor", Components::Editor::Form.new(presenter: @presenter))`. The pending generation state and its completion both go through `Components::Editor::GenerationStatus`.

## Verification Checklist

- [ ] Only the 7 REST actions; transitions extracted to sub-resource controllers
- [ ] No state checks, view helpers, color math or HTML generation
- [ ] Reads via Query Objects, writes via Operations
- [ ] Result branches handled; failures render with `:unprocessable_entity`
- [ ] Turbo Stream renders a dedicated view artifact
- [ ] Base controller lean

## Related Skills

`../operation-pattern`, `../query-object-pattern`, `../phlex-view-pattern` (Turbo Frames/Streams), `../llm-generation`. References: [result-handling.md](references/result-handling.md), [error-handling.md](references/error-handling.md).
