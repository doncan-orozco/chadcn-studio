require "test_helper"

class Components::Editor::GenerationStatusTest < ActiveSupport::TestCase
  test "a failure is a destructive alert with the message, the kept description and both ways on" do
    html = render_status(Generations::Presenter::Status.new(generations(:failed)))

    assert_includes html, 'data-slot="alert"'
    assert_includes html, "Your description is kept in the field."
    assert_includes html, "Try again"
    assert_includes html, "Pick a brand color instead"
    assert_includes html, 'aria-haspopup="dialog"'
    assert_includes html, 'aria-controls="group-brand"'
    assert_includes html, "<svg"
    assert_equal 1, html.scan('role="alert"').size
  end

  test "on New theme the way on is the Brand color field, not a dialog" do
    status = Generations::Presenter::Status.new(Generation.new, failure: :capped)
    html = ApplicationController.render(Components::Editor::GenerationStatus.new(status: status, brand: :field), layout: false)

    assert_includes html, 'data-editor--forward-selector-value="#theme-primary"'
    assert_not_includes html, "aria-haspopup"
    assert_not_includes html, "aria-controls"
  end

  test "a failure that retrying cannot fix offers only the color" do
    html = render_status(Generations::Presenter::Status.new(Generation.new, failure: :busy))

    assert_includes html, "Wait for it to finish"
    assert_includes html, "Pick a brand color instead"
    assert_not_includes html, "Try again"
    assert_not_includes html, "description is kept"
  end

  test "a studio without an API key says how to turn generation on as one muted line, not an alert" do
    html = render_status(Generations::Presenter::Status.new(Generation.new, failure: :not_configured))

    assert_includes html, "set ANTHROPIC_API_KEY and restart the studio"
    assert_includes html, "text-muted-foreground"
    assert_not_includes html, 'role="alert"'
    assert_not_includes html, 'data-slot="alert"'
    assert_not_includes html, "Pick a brand color instead"
  end

  test "pending and done stay plain text in a status region" do
    pending = render_status(Generations::Presenter::Status.new(generations(:pending)))
    done = render_status(Generations::Presenter::Status.new(generations(:completed)))

    [ pending, done ].each do |html|
      assert_includes html, 'role="status"'
      assert_not_includes html, 'data-slot="alert"'
    end
  end

  test "no status renders the empty target" do
    assert_includes render_status(nil), 'id="generation_status"'
  end

  private

  def render_status(status)
    ApplicationController.render(Components::Editor::GenerationStatus.new(status: status), layout: false)
  end
end
