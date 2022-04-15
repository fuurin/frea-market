# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketHistory, type: :model do
  it '作成できる' do
    buyer, seller = 2.times.map { create(:user) }
    item = create(:item, user: seller)
    history = MarketHistory.append!(buyer, seller, item)
    expect(history).to be_truthy
  end

  it 'buyerとsellerが同一の場合は作成時にエラー' do
    seller = create(:user)
    item = create(:item, user: seller)
    expect do
      MarketHistory.append!(seller, seller, item)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
