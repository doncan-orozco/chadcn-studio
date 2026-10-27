# Controller Examples

Controllers are thin - they only receive requests, call Operations, and return responses. Operations return Dry::Monads::Result objects (use result.success? / result.failure?).

## View Boundary Rule

Controllers must not build HTML fragments directly (`view_context.tag`, `tag`, inline HTML strings), including Turbo Stream fragment markup.

For Turbo Stream responses, controllers should render dedicated view artifacts (Phlex component/view or template) and keep presentation concerns (CSS classes, translated copy, markup structure) in the view layer.

When an operation returns a failure payload with an invalid `:model`, render the corresponding form/view with `status: :unprocessable_entity` so the existing model errors are preserved for user feedback.

## ApplicationController Composition Rule

`ApplicationController` should compose cross-cutting concerns, not own feature-specific implementations.

✅ Prefer:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include RequestTiming

  allow_browser versions: :modern
  stale_when_importmap_changes
end
```

❌ Avoid placing full feature stacks (`before_action`, parsing helpers, persistence logic) directly in `ApplicationController`.

## Basic CRUD Controller

```ruby
# app/controllers/game/moves_controller.rb
class Game::MovesController < ApplicationController
  def create
    result = Game::Operation::MovePlayer.new.call(
      params: params.to_unsafe_h,
      current_user: current_user
    )

    if result.success?
      # Broadcast happens inside the Operation
      head :ok
    else
      error_key = result.failure[:error_key]
      case error_key
      when :invalid_move
        render json: { error: result.failure[:error] }, status: :unprocessable_entity
      when :unauthorized
        head :forbidden
      else
        head :internal_server_error
      end
    end
  end
end
```

