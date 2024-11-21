require 'rails_helper'

RSpec.describe RemoveCartItem do
  subject { described_class.new(cart: cart, product_id: product.id).call }

  let(:cart) { create(:cart, total_price: 20) }
  let(:product) { create(:product, price: 10) }

  context 'when there is only one product in the cart' do
    let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    before { cart_item }

    it 'remove cart item from the cart' do
      expect { subject }.to change { CartItem.count }.from(1).to(0)
    end
  end

  context 'when the quantity is greater than 1' do
    let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    before { cart_item }

    it 'reduce the quantity of the cart item' do
      expect { subject }.to change { cart_item.reload.quantity }.from(2).to(1)
    end

    it 'change the total price of the cart' do
      expect { subject }.to change { cart.reload.total_price.to_f }.from(20).to(10)
    end
  end

  context 'when the product is no in the cart'do
    it 'raises error ProductNotAvailableError' do
      expect { subject }.to raise_error(
        described_class::ProductNotAvailableError,
        'Product must exist or was not added in the cart'
      )
    end
  end
end
