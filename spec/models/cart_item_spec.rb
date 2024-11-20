require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when_validating' do
    let(:cart_item) { build(:cart_item, quantity: 0) }

    it 'validates numericality of quantity' do
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'validate quantity type' do
      cart_item.quantity = 1.to_f

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be an integer")
    end

    it 'validate quantity presence' do
      cart_item.quantity = nil

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end
  end

  context '#total_price' do
    let(:product) { build(:product) }
    let(:cart_item) { build(:cart_item, quantity: 2, product: product) }

    it 'returns the total price of the item' do
      total_price = cart_item.quantity * product.price
      expect(cart_item.total_price).to eq(total_price)
    end
  end
end
