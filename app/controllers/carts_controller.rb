class CartsController < ApplicationController
  def show
    render json: {
      id: @current_cart.id,
      products: @current_cart.products.as_json(except: [:created_at, :updated_at])
      .map { |p| p.merge('price' => p['price'].to_f) }
    }
  end
end
