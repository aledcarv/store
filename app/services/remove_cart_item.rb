class RemoveCartItem
  class ProductNotAvailableError < StandardError; end

  def initialize(cart:, product_id:)
    @cart = cart
    @product_id = product_id
  end

  def call
    product_not_available_error!

    return reduce_quantity if cart_item.quantity > 1

    cart_item.destroy!
  end

  private

  def product_not_available_error!
    return if cart_item

    raise ProductNotAvailableError, 'Product must exist or was not added in the cart'
  end

  def cart_item
    @cart_item ||= @cart.cart_items.find_by(product_id: @product_id)
  end

  def reduce_quantity
    quantity = cart_item.quantity

    cart_item.update!(quantity: quantity - 1)
    @cart.update!(total_price: @cart.calculate_total_price)
  end
end
