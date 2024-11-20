class CartsController < ApplicationController
  def show
    render json: ::CartSerializer.new(@current_cart).as_json
  end
end
