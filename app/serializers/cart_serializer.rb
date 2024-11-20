class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def as_json
    { id: @cart.id,
      products: cart_items_serialized }
  end

  private

  def cart_items
    @cart.cart_items
  end

  def cart_items_serialized
    cart_items.map do |cart_item|
      {
        id: cart_item.product_id,
        name: cart_item.product_name,
        quantity: cart_item.quantity,
        unit_price: cart_item.product_price.to_f,
        total_price: cart_item.total_price.to_f
      }
    end
  end
end
