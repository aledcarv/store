require 'rails_helper'

RSpec.describe CartsController, type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

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
            "products" => []
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
                "name" => product.name,
                "price" => product.price
              }
            ]
          }
        )
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
              "products" => []
            }
          )
        end
      end
    end
  end
end
