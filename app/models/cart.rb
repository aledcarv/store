class Cart < ApplicationRecord
  has_many :cart_items
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  enum :status, [:active, :abandoned], default: :active

  def calculate_total_price
    cart_items.sum(&:total_price)
  end
end
