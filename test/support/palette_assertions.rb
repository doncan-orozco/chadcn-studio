# frozen_string_literal: true

module PaletteAssertions
  # A palette the gem would import: complete, plain values, every text pair at 4.5:1, radius only in root.
  def assert_valid_palette(palette, message = nil)
    report = Chadcn::Theme.validate(palette, strict: true)

    assert_empty report[:errors], message
    { "light" => palette.root, "dark" => palette.dark }.each do |mode, variables|
      Chadcn::Theme::CONTRAST_PAIRS.each do |foreground, surface|
        refute_nil Chadcn::Theme.contrast(variables[foreground], variables[surface]), "#{mode}: --#{foreground} on --#{surface} is unjudged"
      end
    end

    assert_equal Chadcn::Theme::REQUIRED.sort, palette.dark.keys.sort, "dark must hold exactly the required variables"
    assert_equal (Chadcn::Theme::REQUIRED + Chadcn::Theme::ROOT_ONLY).sort, palette.root.keys.sort
  end
end
