class ApplicationController < ActionController::API
  before_action :current_cart

  private

  def current_cart
    cart = Cart.last
    if cart
      @current_cart = cart
    else
      @current_cart = Cart.create!(total_price: 0)
    end
  end
end
