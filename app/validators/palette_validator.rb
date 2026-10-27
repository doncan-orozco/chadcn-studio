class PaletteValidator < ActiveModel::Validator
  def validate(record)
    return record.errors.add(:base, "palette must have light and dark variables") unless record.light.is_a?(Hash) && record.dark.is_a?(Hash)

    # Contrast is a warning at save time; derivation runs strict: true (theme-science R8).
    Chadcn::Theme.validate(record.palette, strict: false)[:errors].each { |message| record.errors.add(:base, message) }
  end
end
