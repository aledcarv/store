class AddItemsController < ApplicationController
  # TODO: move code to another class and add exceptions
  def update
    if params[:quantity].to_i.zero?
      render json: { error: "Quantity can't be blank" }, status: :bad_request
    elsif params[:product_id].to_i.zero?
      render json: { error: 'Product must exist' }, status: :bad_request
    else
      cart_item = @current_cart.cart_items.find_by(product_id: params[:product_id])

      if cart_item
        current_quantity = cart_item.quantity
        quantity = current_quantity + params[:quantity].to_i

        cart_item.update!(quantity: quantity)
        @current_cart.update!(total_price: @current_cart.calculate_total_price)

        render json: CartSerializer.new(@current_cart).as_json, status: :ok
      else
        render json: { error: 'Product must exist' }, status: :bad_request
      end
    end
  end
end
