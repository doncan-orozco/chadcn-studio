require "test_helper"

# Measures the derivation constants (theme-science: they were written from zinc, not measured): every sampled primary must
# derive a palette the gem accepts strictly, within the repair budget.
class Themes::Service::HarmonyCalibrationTest < ActiveSupport::TestCase
  include PaletteAssertions

  PRESETS_DIR = Rails.root.join("app/assets/tailwind/theme/presets")
  PRESET_PRIMARIES = Dir[PRESETS_DIR.join("*.css")].sort.to_h do |file|
    [ File.basename(file, ".css"), Chadcn::Theme.parse(File.read(file)).root.fetch("primary") ]
  end
  GRID = [ 0.45, 0.55, 0.65 ].product([ 0.12, 0.2 ], (0...360).step(30).to_a).map do |lightness, chroma, hue|
    [ "L#{lightness} C#{chroma} H#{hue}", "oklch(#{lightness} #{chroma} #{hue})" ]
  end.to_h

  test "the gem's six presets are sampled" do
    assert_equal 6, PRESET_PRIMARIES.size
  end

  PRESET_PRIMARIES.merge(GRID).each do |label, primary|
    test "derives a strictly valid palette within the repair budget for #{label}" do
      result = Themes::Service::Harmony.derive(primary: primary)

      assert_valid_palette result.palette, "#{label} #{primary}"
      assert_operator result.repairs, :<=, Themes::Service::Harmony::REPAIR_MAX_STEPS, "#{label} needed #{result.repairs} repairs"
    end
  end
end
