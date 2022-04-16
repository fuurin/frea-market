# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketHistory, type: :model do
  describe '#append!' do
    let!(:buyer) do
      user = create(:user)
      user.update!(point: 1000)
      user
    end
    let!(:seller) do
      user = create(:user)
      user.update!(point: 1000)
      user
    end
    let!(:item) { create(:item, user: seller, point: 500) }

    it 'buyer, seller, itemを指定して売買履歴を作成できる' do
      history = MarketHistory.append!(buyer, seller, item)

      expect(history).to be_truthy
      expect(history.buyer_id).to eq buyer.id
      expect(history.buyer_point_to).to eq 500
      expect(history.seller_id).to eq seller.id
      expect(history.seller_point_to).to eq 1500
      expect(history.item_id).to eq item.id
    end

    context '失敗' do
      it '購入時のポイントが足りなければ作成できない' do
        item.update!(point: 10_000)
        expect do
          MarketHistory.append!(buyer, seller, item)
        end.to raise_error(ActiveRecord::RecordInvalid)
        expect(MarketHistory.count).to eq 0
      end

      it 'buyerとsellerが同一の場合は作成できない' do
        expect do
          MarketHistory.append!(buyer, buyer, item)
        end.to raise_error(ActiveRecord::RecordInvalid)
        expect(MarketHistory.count).to eq 0
      end
    end
  end
end
