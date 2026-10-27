require "test_helper"

# `design-system` R13: every theme variable is visibly used by at least one preview page.
class VariableCoverageTest < ActionDispatch::IntegrationTest
  UTILITY_PREFIXES = %w[bg text border ring fill stroke outline divide from to via].freeze

  test "every Chadcn::Theme::REQUIRED variable has a utility class inside the preview root of the pages" do
    classes = Views::Previews::PAGES.each_key.flat_map { |page| preview_root_classes(page) }

    missing = Chadcn::Theme::REQUIRED.reject do |name|
      classes.any? { |klass| klass.match?(/\A(?:#{UTILITY_PREFIXES.join('|')})-#{Regexp.escape(name)}\z/) }
    end

    assert_empty missing, "no preview page uses: #{missing.join(', ')}"
  end

  private

  # Class tokens of the nodes inside the preview root, variants (hover:, dark:) and /opacity stripped.
  def preview_root_classes(page)
    get preview_path(page)
    root = Nokogiri::HTML5(response.body).at_css("[data-testid=preview-root]")
    root.css("[class]").flat_map { |node| node["class"].split }.map { |token| token.split(":").last.sub(%r{/\d+\z}, "") }
  end
end
