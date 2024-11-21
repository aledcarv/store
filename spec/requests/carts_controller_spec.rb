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

  describe 'DELETE /cart/:product_id' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    context 'when removing a product from the cart' do
      context 'and have only one product' do
        let(:cart_item) do
          create(:cart_item, cart: cart, product: product, quantity: 1)
        end

        before { cart_item }

        it 'cart item is removed' do
          delete "/cart/#{product.id}"

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(
            {
              "id" => cart.id,
              "products" => [],
              "total_price" => cart.total_price
            }
          )
        end
      end

      context 'and have more than one product with the same product_id' do
        let(:cart_item) do
          create(:cart_item, cart: cart, product: product, quantity: 2)
        end
        let(:current_quantity) { 1 }

        before { cart_item }

        it 'reduce the quantity' do
          delete "/cart/#{product.id}"

          cart_item.reload

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(
            {
              "id" => cart.id,
              "products" => [
                {
                  "id" => product.id,
                  "name" => cart_item.product_name,
                  "quantity" => current_quantity,
                  "unit_price" => cart_item.product_price,
                  "total_price" => cart_item.total_price
                }
              ],
              "total_price" => cart.total_price.to_f
            }
          )
        end
      end

      context 'and added a nonexistent product_id' do
        it 'show message error' do
          delete '/cart/600'

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Product must exist or was not added in the cart' })
        end
      end

      context 'and the product is not in the cart' do
        it 'show message error' do
          delete "/cart/#{product.id}"

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)).to eq({ 'error' => 'Product must exist or was not added in the cart' })
        end
      end
    end
  end
end
