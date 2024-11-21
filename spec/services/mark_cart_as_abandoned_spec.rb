require 'rails_helper'

RSpec.describe MarkCartAsAbandoned do
  subject { described_class.call }

  context 'when cart is abandoned for 3 hours' do
    let(:cart) { create(:cart) }

    before { cart.update!(updated_at: 3.hours.ago) }

    it 'change status to abandoned' do
      expect { subject }.to change { cart.reload.status }.from('active').to('abandoned')
    end
  end

  context 'when cart is abandoned for 7 days' do
    let(:cart) { create(:cart) }

    before { cart.update!(status: :abandoned, updated_at: 7.days.ago) }

    it 'change status to abandoned' do
      expect { subject }.to change { Cart.count }.from(1).to(0)
    end
  end
end
