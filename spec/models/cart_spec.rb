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

  context 'enums' do
    let(:cart) { build(:cart) }

    it 'defaults to active status' do
      expect(cart).to be_active
    end

    it 'defines status values' do
      expect(Cart.statuses).to eq({ "active" => 0, "abandoned" => 1 })
    end
  end

  describe 'scopes' do
    describe '.all_abandoned' do
      let!(:recent_active_cart) { create(:cart, updated_at: 2.hours.ago, status: :active) }
      let!(:old_active_cart) { create(:cart, updated_at: 4.hours.ago, status: :active) }
      let!(:old_abandoned_cart) { create(:cart, updated_at: 4.hours.ago, status: :abandoned) }

      it 'returns active carts that have not been updated for 3 hours' do
        expect(Cart.all_abandoned).to include(old_active_cart)
        expect(Cart.all_abandoned).not_to include(recent_active_cart)
        expect(Cart.all_abandoned).not_to include(old_abandoned_cart)
      end
    end

    describe '.old_abandoned' do
      let!(:recent_abandoned_cart) { create(:cart, updated_at: 6.days.ago, status: :abandoned) }
      let!(:old_abandoned_cart) { create(:cart, updated_at: 8.days.ago, status: :abandoned) }
      let!(:old_active_cart) { create(:cart, updated_at: 8.days.ago, status: :active) }

      it 'returns abandoned carts that have not been updated for 7 days' do
        expect(Cart.old_abandoned).to include(old_abandoned_cart)
        expect(Cart.old_abandoned).not_to include(recent_abandoned_cart)
        expect(Cart.old_abandoned).not_to include(old_active_cart)
      end
    end
  end
end
