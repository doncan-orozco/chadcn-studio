require "test_helper"

class GalleryControllerTest < ActionDispatch::IntegrationTest
  test "GET /gallery is 200 with one section per catalog entry, id equal to the component name" do
    get gallery_path

    assert_response :success
    Chadcn::Catalog.entries.each do |entry|
      assert_select "section##{entry.component}[data-testid=gallery-entry]", 1, "missing section for #{entry.component}"
    end
  end

  test "no entry fell back to the error notice" do
    get gallery_path

    assert_select "[data-testid=gallery-error]", 0
  end

  test "the sticky index links every component" do
    get gallery_path

    Chadcn::Catalog.entries.each { |entry| assert_select "nav[aria-label=Components] a[href='##{entry.component}']" }
  end

  test "an entry whose tree cannot render shows a notice and the rest still renders" do
    broken = Chadcn::Catalog::Entry.new(component: "broken", title: "Broken", scenario_id: "x", scenario_count: 1, tree: { "c" => "NoSuchThing" }.freeze)
    entries = [ broken, *Chadcn::Catalog.entries.first(2) ]
    presenter = Gallery::Presenter::Index.new(entries:)

    html = Views::Gallery::Show.new(presenter).call

    assert_includes html, "This demo could not be rendered"
    assert_includes html, %(id="#{entries.last.component}")
  end

  test "each entry shows its title and scenario count, under alphabetical letter groups" do
    get gallery_path

    Chadcn::Catalog.entries.each do |entry|
      assert_select "section##{entry.component} h3", text: entry.title
      assert_select "section##{entry.component} span", text: /\A#{entry.scenario_count} scenarios?\z/
    end
    letters = css_select("section[aria-label^='Components starting'] > h2").map { |heading| heading.text.strip }

    assert_equal letters.sort, letters
    assert_equal letters.uniq, letters
  end

  test "the scenario label is singular for one scenario" do
    entry = Chadcn::Catalog::Entry.new(component: "solo", title: "Solo", scenario_id: "x", scenario_count: 1, tree: { "c" => "_div" }.freeze)
    presenter = Gallery::Presenter::Index.new(entries: [ entry ])

    assert_equal "1 scenario", presenter.scenario_label(entry)
    assert_equal [ "S" ], presenter.groups.map(&:letter)
    assert_equal "#solo", presenter.anchor_href(entry)
  end

  test "a tree that fails below the root leaves no partial markup and later entries stay top-level" do
    nested = Chadcn::Catalog::Entry.new(component: "a-broken", title: "A broken", scenario_id: "x", scenario_count: 2,
                                        tree: { "c" => "Card", "children" => [ { "c" => "NoSuchThing" } ] }.freeze)
    entries = [ nested, *Chadcn::Catalog.entries.first(2) ]

    html = Nokogiri::HTML5.fragment(Views::Gallery::Show.new(Gallery::Presenter::Index.new(entries:)).call)

    assert_empty html.css("section#a-broken [data-slot=card]")
    assert_equal 1, html.css("section#a-broken [data-testid=gallery-error]").size
    entries.drop(1).each { |entry| assert_empty html.css("section#a-broken section##{entry.component}") }
  end

  test "a broken tree is reported to the error reporter" do
    broken = Chadcn::Catalog::Entry.new(component: "broken", title: "Broken", scenario_id: "x", scenario_count: 1, tree: { "c" => "NoSuchThing" }.freeze)

    assert_error_reported(Chadcn::Catalog::TreeRenderer::Error) do
      Views::Gallery::Show.new(Gallery::Presenter::Index.new(entries: [ broken ])).call
    end
  end
end
