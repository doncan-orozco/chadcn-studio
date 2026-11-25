# frozen_string_literal: true

# A prompt and no theme yet -> a placeholder theme and a pending generation for it, job enqueued. The placeholder holds the
# default palette until the generation replaces it, and is removed again when the generation cannot start, so a refused
# prompt leaves nothing behind. Failures are `Request`'s (:busy, :capped, :invalid).
class Generations::Operation::Begin < Core::Operation
  PLACEHOLDER_PRIMARY = "#71717a"
  NAME_LIMIT = 40
  private_constant :PLACEHOLDER_PRIMARY, :NAME_LIMIT

  def initialize(create: Themes::Operation::Create.new, request: Generations::Operation::Request.new)
    @create = create
    @request = request
    super()
  end

  def call(prompt:, hourly_cap: nil)
    text = prompt.to_s.strip
    fail_with_model!(Generation.new(prompt: text), code: :invalid) if text.empty?

    theme = step placeholder(text)
    generation = step request(theme, text, hourly_cap)

    { model: theme, generation: generation }
  end

  private

  def placeholder(text)
    created = @create.call(name: text.truncate(NAME_LIMIT), primary: PLACEHOLDER_PRIMARY)
    created.success? ? Success(created.value![:model]) : created
  end

  def request(theme, text, hourly_cap)
    requested = @request.call(theme: theme, prompt: text, hourly_cap: hourly_cap)
    return Success(requested.value![:model]) if requested.success?

    theme.destroy
    requested
  rescue StandardError
    theme.destroy
    raise
  end
end
