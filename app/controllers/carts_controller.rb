class CartsController < ApplicationController
  def show
    render json: ::CartSerializer.new(@current_cart).as_json
  end

  def update
    ::AddProductInCart.new(**send_args).call

    render json: CartSerializer.new(@current_cart).as_json, status: :ok
  rescue ::AddProductInCart::ProductAlreadyInCartError => e
    render json: { error: e.message }, status: :conflict
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :bad_request
  end

  # TODO: apply refactoring in the action destroy
  def destroy
    cart_item = @current_cart.cart_items.find_by(product_id: params[:product_id])

    if cart_item
      if cart_item.quantity > 1
        quantity = cart_item.quantity

        cart_item.update!(quantity: quantity - 1)
        @current_cart.update!(total_price: @current_cart.calculate_total_price)

        render json: CartSerializer.new(@current_cart).as_json, status: :ok
      else
        if cart_item.destroy!
          render json: CartSerializer.new(@current_cart).as_json, status: :ok
        end
      end
    else
      render json: { error: 'Product must exist or was not added in the cart' }, status: :bad_request
    end
  end

  private

  def cart_item_params
    params.permit(:product_id, :quantity)
  end

  def send_args
    { product_id: cart_item_params[:product_id],
      quantity: cart_item_params[:quantity],
      cart: @current_cart }
  end
end
