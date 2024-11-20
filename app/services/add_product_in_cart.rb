class AddProductInCart
  class ProductAlreadyInCartError < StandardError; end

  def initialize(product_id:, quantity:, cart:)
    @product_id = product_id.to_i
    @quantity = quantity
    @cart = cart
  end

  def call
    raise ProductAlreadyInCartError, 'product already in the cart' if product_already_in_the_cart?

    cart_item = CartItem.new(cart_id: @cart.id, product_id: @product_id, quantity: @quantity)

    cart_item.save!
  end

  private

  def product_already_in_the_cart?
    @product_id.in?(products_in_cart)
  end

  def products_in_cart
    @cart.products.pluck(:id)
  end
end
