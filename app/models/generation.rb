class Generation < ApplicationRecord
  belongs_to :theme

  validates :prompt, presence: true, length: { maximum: 2000 }

  def pending? = completed_at.nil? && failed_at.nil?
  def completed? = completed_at.present?
  def failed? = failed_at.present?
end
