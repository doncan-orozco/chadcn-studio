require "test_helper"

class Components::Gallery::DemoOutlineTest < ActiveSupport::TestCase
  def outline(html) = Components::Gallery::DemoOutline.call(html)

  test "shifts the whole set so the hierarchy is kept below the entry title" do
    assert_equal "<h4>A</h4><h5>B</h5>", outline("<h2>A</h2><h3>B</h3>")
  end

  test "leaves headings already at or below the floor alone" do
    html = "<h5>A</h5><h6>B</h6>"

    assert_equal html, outline(html)
  end

  test "clamps a shifted heading at h6" do
    assert_equal "<h4>A</h4><h6>B</h6>", outline("<h1>A</h1><h6>B</h6>")
  end

  test "returns the input unchanged when there are no headings" do
    html = "<p>Plain <a href=\"#\">link</a></p>"

    assert_equal html, outline(html)
  end

  test "never touches links" do
    assert_equal "<h4>A</h4><a href=\"#\">x</a><a href=\"#nope\">y</a>", outline("<h1>A</h1><a href=\"#\">x</a><a href=\"#nope\">y</a>")
  end
end
