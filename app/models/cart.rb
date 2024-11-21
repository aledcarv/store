class Cart < ApplicationRecord
  has_many :cart_items
  has_many :products, through: :cart_items

  scope :all_abandoned, -> { where('updated_at < ?', 3.hours.ago).active }
  scope :old_abandoned, -> { where('updated_at < ?', 7.days.ago).abandoned }

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  enum :status, [:active, :abandoned], default: :active

  def calculate_total_price
    cart_items.sum(&:total_price)
  end
end
