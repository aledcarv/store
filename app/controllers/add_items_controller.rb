class AddItemsController < ApplicationController
  def update
    IncreaseCartItemQuantity.new(**send_args).call

    render json: CartSerializer.new(@current_cart).as_json, status: :ok
  rescue IncreaseCartItemQuantity::ErrorHandler => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def send_args
    { product_id: params[:product_id].to_i,
      quantity: params[:quantity].to_i,
      cart: @current_cart }
  end
end
