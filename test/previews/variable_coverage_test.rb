require "test_helper"

# `design-system` R13: every theme variable is visibly used by at least one preview page.
class VariableCoverageTest < ActionDispatch::IntegrationTest
  UTILITY_PREFIXES = %w[bg text border ring fill stroke outline divide from to via].freeze

  test "every Chadcn::Theme::REQUIRED variable has a utility class in the rendered preview pages" do
    html = Views::Previews::PAGES.map { |page| get(preview_path(page)) && response.body }.join("\n")

    missing = Chadcn::Theme::REQUIRED.reject do |name|
      html.match?(/(?:#{UTILITY_PREFIXES.join('|')})-#{Regexp.escape(name)}(?![\w-])/)
    end

    assert_empty missing, "no preview page uses: #{missing.join(', ')}"
  end
end
