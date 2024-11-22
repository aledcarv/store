require 'rails_helper'

RSpec.describe AddItemsController, type: :request do
  describe 'PUT /cart/add_item' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 5.0) }
    let(:cart_item) { create(:cart_item, cart: cart, product: product) }

    before { cart_item }

    context 'when the product already is in the cart' do
      it 'updates the quantity of the existing item in the cart' do
        expect do
          put '/cart/add_item', params: { product_id: product.id, quantity: 1 }
        end.to change { cart_item.reload.quantity }.from(1).to(2)
      end

      it 'updates the total_price' do
        expect do
          put '/cart/add_item', params: { product_id: product.id, quantity: 1 }
        end.to change { cart_item.reload.total_price.to_f }.from(5.0).to(10.0)
      end
    end

    context 'and quantity is not provided' do
      it 'show message error' do
        put '/cart/add_item', params: { product_id: product.id }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(
          {
            "error" => "Quantity can't be blank"
          }
        )
      end
    end

    context 'and product_id does not exist' do
      it 'show message error' do
        put '/cart/add_item', params: { product_id: 548, quantity: 1 }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(
          {
            "error" => "Product must exist or was not added in the cart"
          }
        )
      end
    end

    context 'and product_id is not provided' do
      it 'show message error' do
        put '/cart/add_item', params: { quantity: 1 }

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq(
          {
            "error" => "Product must be passed"
          }
        )
      end
    end
  end
end
