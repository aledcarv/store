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
