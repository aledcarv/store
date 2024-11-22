require 'rails_helper'

RSpec.describe IncreaseCartItemQuantity do
  subject do
    described_class
      .new(cart: cart, quantity: quantity, product_id: product_id)
      .call
  end

  let(:cart) { create(:cart, total_price: 20) }
  let(:product) { create(:product, price: 20) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
  let(:product_id) { product.id }
  let(:quantity) { cart_item.quantity }

  context 'when the product already is in the cart' do
    before { cart_item }

    it 'updates the quantity of the existing item in the cart' do
      expect { subject }.to change { cart_item.reload.quantity }.from(1).to(2)
    end

    it 'updates the total price of the cart' do
      expect { subject }.to change { cart.reload.total_price }.from(20).to(40)
    end
  end

  context 'when the product is not in the cart' do
    let(:product_id) { 500 }

    it 'raises error ProductNotAvailableError' do
      expect { subject }.to raise_error(
        described_class::ProductNotAvailableError,
        'Product must exist or was not added in the cart'
      )
    end
  end

  context 'when quantity is nil' do
    let(:quantity) { nil }

    it 'raises error BlankQuantityError' do
      expect { subject }.to raise_error(
        described_class::BlankQuantityError, "Quantity can't be blank"
      )
    end
  end

  context 'when product_id is nil' do
    let(:product_id) { nil }

    it 'raises error BlankProductError' do
      expect { subject }.to raise_error(
        described_class::BlankProductError, 'Product must be passed'
      )
    end
  end
end
