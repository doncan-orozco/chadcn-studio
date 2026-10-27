class PaletteValidator < ActiveModel::Validator
  def validate(record)
    return record.errors.add(:base, "palette must have light and dark variables") unless record.light.is_a?(Hash) && record.dark.is_a?(Hash)

    Chadcn::Theme.validate(record.palette)[:errors].each { |message| record.errors.add(:base, message) }
  end
end
