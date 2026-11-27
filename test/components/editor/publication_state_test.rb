require "test_helper"

class Components::Editor::PublicationStateTest < ActiveSupport::TestCase
  def render_state(theme)
    sharing = Exports::Presenter::Sharing.new(theme, base_url: "https://studio.test")
    Nokogiri::HTML.fragment(ApplicationController.render(Components::Editor::PublicationState.new(presenter: sharing), layout: false))
  end

  test "a draft reads Not published and shows no link" do
    html = render_state(themes(:zinc))

    assert_equal "Not published", html.at_css("[data-testid=publication-state]").text.strip
    assert_nil html.at_css("[data-testid=publication-link]")
  end

  test "a published theme reads Published with its public link" do
    html = render_state(themes(:slate))

    assert_equal "Published", html.at_css("[data-testid=publication-state]").text.strip
    assert_equal "/t/slate.css", html.at_css("[data-testid=publication-link]")["href"]
  end

  test "the root carries the id a Turbo Stream replaces" do
    assert_equal Components::Editor::PublicationState::ID, render_state(themes(:slate)).at_css("span")["id"]
  end
end
