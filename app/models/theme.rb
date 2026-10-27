class Theme < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9-]+\z/

  has_many :generations, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true, format: { with: SLUG_FORMAT }
  validates :light, :dark, :inputs, exclusion: { in: [ nil ], message: "can't be blank" }
  validates_with PaletteValidator

  def palette = Chadcn::Theme::Palette.new(root: light, dark: dark)

  def published? = published_at.present?
end
