class IncreaseCartItemQuantity
  class ErrorHandler < StandardError; end
  class BlankQuantityError < ErrorHandler; end
  class BlankProductError < ErrorHandler; end
  class ProductNotAvailableError < ErrorHandler; end

  def initialize(cart:, quantity:, product_id:)
    @cart = cart
    @quantity = quantity
    @product_id = product_id
  end

  def call
    validate!

    cart_item.update!(quantity: updated_quantity)
    @cart.update!(total_price: @cart.calculate_total_price)
  end

  private

  def validate!
    validate_quantity!
    validate_product!
    validate_product_presence!
  end

  def validate_quantity!
    raise BlankQuantityError, "Quantity can't be blank" if @quantity.to_i.zero?
  end

  def validate_product!
    raise BlankProductError, 'Product must be passed' if @product_id.to_i.zero?
  end

  def cart_item
    @cart_item ||= @cart.cart_items.find_by(product_id: @product_id)
  end

  def validate_product_presence!
    return if cart_item

    raise ProductNotAvailableError, 'Product must exist or was not added in the cart'
  end

  def current_quantity
    cart_item.quantity
  end

  def updated_quantity
    current_quantity + @quantity
  end
end
