require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    let(:cart) { build(:cart, total_price: -1) }

    it 'validates numericality of total_price' do
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  context '#calculate_total_price' do
    let(:cart) { create(:cart, total_price: 0) }
    let(:product) { create(:product, price: 15) }
    let(:product_2) { create(:product, price: 10) }
    let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
    let(:cart_item_2) { create(:cart_item, cart: cart, product: product_2, quantity: 1) }

    before do
      cart_item
      cart_item_2
    end

    it 'calculates the total price of the products in the cart' do
      expect(cart.calculate_total_price).to eq(40)
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
