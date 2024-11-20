class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: {
      id: @cart.id,
      products: @cart.products.as_json(except: [:created_at, :updated_at])
      .map { |p| p.merge('price' => p['price'].to_f) }
    }
  end

  private

  def set_cart
    @cart = Cart.last
  end
end
