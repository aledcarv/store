class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  delegate :name, :price, to: :product, prefix: :product

  def total_price
    product_price * quantity
  end
end
