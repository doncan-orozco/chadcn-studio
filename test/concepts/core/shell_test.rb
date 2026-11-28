require "test_helper"

class Core::ShellTest < ActionDispatch::IntegrationTest
  test "root renders the shell with the theme toggle and the toaster" do
    get root_path

    assert_response :success
    assert_select "[data-testid=shell]"
    assert_select "[data-testid=theme-toggle] [data-testid=theme-trigger]", text: "Studio appearance"
    assert_select "section[aria-live=polite]"
    assert_select "[data-testid=sidebar]", count: 0
  end

  test "the brand link is a 24 px target and the appearance menu is wired to the theme controller" do
    get root_path

    assert_select "a[href='/'].min-h-6"
    assert_select "[data-testid=theme-toggle][data-controller~='chadcn--theme'][data-controller~='shell--theme-toggle']"
    %w[light dark system].each do |mode|
      assert_select "template [data-testid=theme-#{mode}][role=menuitemradio]"
    end
  end

  test "the header names the studio's appearance once and keeps the hint for screen readers" do
    get root_path

    assert_select "[data-testid=theme-trigger][aria-describedby=studio-appearance-hint]", text: "Studio appearance"
    assert_select "#studio-appearance-hint.sr-only", text: "Does not change the theme preview."
    assert_select "#studio-appearance", count: 0
  end

  test "the frame renders an html_safe sidebar and refuses a plain string" do
    assert_nothing_raised { Components::Shell::Frame.new(sidebar: ActiveSupport::SafeBuffer.new("<nav></nav>")) }
    assert_nothing_raised { Components::Shell::Frame.new }
    assert_raises(ArgumentError) { Components::Shell::Frame.new(sidebar: "<script>alert(1)</script>") }
  end

  test "every v1 route is declared" do
    routes = Rails.application.routes.routes.map { |route| route.defaults.values_at(:controller, :action).join("#") }

    %w[themes#index themes#create themes#new themes#edit themes#show themes#update themes#destroy
       themes/derivations#create themes/publications#create themes/publications#destroy
       themes/generations#create themes/exports#show previews#show gallery#show].each do |endpoint|
      assert_includes routes, endpoint
    end
  end

  test "the export url takes css and json" do
    assert_equal "/t/zinc.css", theme_export_path(slug: "zinc", format: :css)
    assert_equal "/t/zinc.json", theme_export_path(slug: "zinc", format: :json)
  end
end
