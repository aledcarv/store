require 'rails_helper'

RSpec.describe CartsController, type: :request do
  describe "GET /cart" do
    context 'when the cart is empty' do
      let(:cart) { create(:cart) }

      before { cart }

      it 'shows cart response' do
        get '/cart'

        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq(
          {
            "id" => cart.id,
            "products" => [],
            "total_price" => cart.total_price
          }
        )
      end
    end

    context 'when cart is full' do
      let(:cart) { create(:cart) }
      let(:product) { create(:product) }
      let(:cart_item) { create(:cart_item, cart: cart, product: product) }

      before { cart_item }

      it 'shows cart response' do
        get '/cart'

        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq(
          {
            "id" => cart.id,
            "products" => [
              {
                "id" => product.id,
                "name" => cart_item.product_name,
                "quantity" => cart_item.quantity,
                "unit_price" => cart_item.product_price,
                "total_price" => cart_item.total_price
              }
            ],
            "total_price" => cart.total_price
          }
        )
      end

      context 'and has more than one product' do
        let(:product_2) { create(:product, name: 'product B') }
        let(:cart_item_2) { create(:cart_item, cart: cart, product: product_2) }

        before { cart_item_2 }

        it 'shows cart response' do
          get '/cart'

          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq(
            {
              "id" => cart.id,
              "products" => [
                {
                  "id" => product.id,
                  "name" => cart_item.product_name,
                  "quantity" => cart_item.quantity,
                  "unit_price" => cart_item.product_price,
                  "total_price" => cart_item.total_price
                },
                {
                  "id" => product_2.id,
                  "name" => cart_item_2.product_name,
                  "quantity" => cart_item_2.quantity,
                  "unit_price" => cart_item_2.product_price,
                  "total_price" => cart_item_2.total_price
                }
              ],
              "total_price" => cart.total_price
            }
          )
        end
      end
    end

    context 'when cart was not previowsly created' do
      context 'and the cart is empty' do
        it 'shows cart response' do
          get '/cart'

          expect(response).to be_successful
          expect(JSON.parse(response.body)).to eq(
            {
              "id" => Cart.last.id,
              "products" => [],
              "total_price" => Cart.last.total_price
            }
          )
        end
      end
    end
  end

  describe 'PUT /cart' do
    context 'when the product is not in the cart' do
      let(:product) { create(:product) }

      it 'add product in the cart' do
        put '/cart', params: { product_id: product.id, quantity: 1 }

        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq(
          {
            "id" => Cart.last.id,
            "products" => [
              {
                "id" => product.id,
                "name" => CartItem.last.product_name,
                "quantity" => CartItem.last.quantity,
                "unit_price" => CartItem.last.product_price,
                "total_price" => CartItem.last.total_price
              }
            ],
            "total_price" => Cart.last.total_price
          }
        )
      end

      context 'and quantity is not provided' do
        it 'show message error' do
          put '/cart', params: { product_id: product.id }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq(
            {
              "error" => "Validation failed: Quantity can't be blank, Quantity is not a number"
            }
          )
        end
      end

      context 'and quantity is zero' do
        it 'show message error' do
          put '/cart', params: { product_id: product.id, quantity: 0 }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq(
            {
              "error" => "Validation failed: Quantity must be greater than 0"
            }
          )
        end
      end

      context 'and product_id is not provided' do
        it 'show message error' do
          put '/cart', params: { quantity: 1 }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq(
            {
              "error" => "Validation failed: Product must exist"
            }
          )
        end
      end

      context 'and product_id does not exist' do
        it 'show message error' do
          put '/cart', params: { product_id: 548, quantity: 1 }

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq(
            {
              "error" => "Validation failed: Product must exist"
            }
          )
        end
      end

      context 'and try to add product already in the cart' do
        let(:cart) { create(:cart) }
        let(:cart_item) { create(:cart_item, product: product, cart: cart) }

        before { cart_item }

        it 'show message error' do
          put '/cart', params: { product_id: product.id, quantity: 1 }

          expect(response).to have_http_status(:conflict)
          expect(JSON.parse(response.body)).to eq(
            {
              "error" => "product already in the cart"
            }
          )
        end
      end
    end
  end
end
