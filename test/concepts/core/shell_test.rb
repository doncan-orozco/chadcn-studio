require "test_helper"

class Core::ShellTest < ActionDispatch::IntegrationTest
  test "root renders the shell with the theme toggle and the toaster" do
    get root_path

    assert_response :success
    assert_select "[data-testid=shell]"
    assert_select "[data-testid=theme-toggle] [data-action='chadcn--theme#setDark']"
    assert_select "section[aria-live=polite]"
    assert_select "[data-testid=sidebar]", count: 0
  end

  test "the brand link is a 24 px target and the scheme buttons expose a pressed state" do
    get root_path

    assert_select "a[href='/'].min-h-6"
    assert_select "[data-testid=theme-toggle][data-controller~='chadcn--theme'][data-controller~='shell--theme-toggle']"
    %w[light dark system].each do |mode|
      assert_select "[data-testid=theme-#{mode}][aria-pressed=false]"
    end
  end

  test "the preview mode row is a full-width 24 px target" do
    fragment = Nokogiri::HTML5.fragment(Components::Editor::ModeSwitch.new.call)

    assert fragment.at_css("div.w-full.min-h-6 > label.flex-1.min-h-6[for=preview-dark]")
    assert fragment.at_css("div.w-full.min-h-6 > [id=preview-dark]")
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
