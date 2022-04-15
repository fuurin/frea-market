# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/v1/market', type: :request do
  describe 'GET #show' do
    let(:users) { 3.times.map { create(:user) } }

    context 'ログインしていないとき' do
      it '販売されている全ての商品をページングで取得できる' do
        page_size = Settings.models.item.page_size
        market_items = (page_size + 1).times.map { |i| create(:item, user: users[i % users.size]) }

        get v1_market_path
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq page_size
        expect(items.map { |item| item['id'] }.sort).to eq market_items.last(page_size).map(&:id).sort

        get v1_market_path, params: { page: 2 }
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq 1
        expect(items.first['id']).to eq market_items.first.id
      end

      it '販売者が削除された商品は結果に含まない' do
        market_items = 3.times.map { users.map { |user| create(:item, user: user) } }.flatten
        deleted_user = users.first
        deleted_user.destroy!
        get v1_market_path
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq 6
        expected_items = market_items.filter { |item| item.user_id != deleted_user.id }.map(&:id).sort
        expect(items.map { |item| item['id'] }.sort).to eq expected_items
      end
    end

    context 'ログインしているとき' do
      let!(:login_user) { create(:user) }
      let!(:user_items) { 5.times { create(:item, user: login_user) } }

      it 'ログイン中ユーザ以外によって販売されている商品をページングで取得できる' do
        page_size = Settings.models.item.page_size
        market_items = (page_size + 1).times.map { |i| create(:item, user: users[i % users.size]) }

        get v1_market_path, headers: authorized_headers(login_user)
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq page_size
        expect(items.map { |item| item['id'] }.sort).to eq market_items.last(page_size).map(&:id).sort

        get v1_market_path, params: { page: 2 }, headers: authorized_headers(login_user)
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq 1
        expect(items.first['id']).to eq market_items.first.id
      end

      it '販売者が削除された商品は結果に含まない' do
        market_items = 3.times.map { users.map { |user| create(:item, user: user) } }.flatten
        deleted_user = users.first
        deleted_user.destroy!
        get v1_market_path, headers: authorized_headers(login_user)
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq 6
        expected_items = market_items.filter { |item| item.user_id != deleted_user.id }.map(&:id).sort
        expect(items.map { |item| item['id'] }.sort).to eq expected_items
      end
    end
  end

  describe 'POST #buy' do
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

    it '購入に成功すると201を返し、売買履歴を返す' do
      post v1_market_buy_path(item), headers: authorized_headers(buyer)
      expect(response.status).to eq 201

      history = JSON.parse(response.body)
      expect(history).to be_truthy
      expect(history['buyer_id']).to eq buyer.id
      expect(history['buyer_point_to']).to eq 500
      expect(history['seller_id']).to eq seller.id
      expect(history['seller_point_to']).to eq 1500
      expect(history['item_id']).to eq item.id

      [buyer, seller].each(&:reload)
      expect(buyer.point).to eq 500
      expect(seller.point).to eq 1500
      expect(Item.find_by(id: item.id)).to be_nil
    end

    context '異常系' do
      after do
        expect(MarketHistory.count).to eq 0
        [buyer, seller].each(&:reload)
        expect(buyer.point).to eq 1000
        expect(seller.point).to eq 1000
        expect(Item.find_by(id: item.id)).to be_truthy
      end

      it 'ログインしていなければ401を返し、何もしない' do
        post v1_market_buy_path(item)
        expect(response.status).to eq 401
      end

      it '購入する商品が存在しなければ404を返し、何もしない' do
        post v1_market_buy_path(0), headers: authorized_headers(buyer)
        expect(response.status).to eq 404
      end

      it '購入時のポイントが足りなければ422を返し、何もしない' do
        item.update!(point: 10_000)

        post v1_market_buy_path(item), headers: authorized_headers(buyer)
        expect(response.status).to eq 422
      end

      it 'buyerとsellerが同一の場合は422を返し、何もしない' do
        item.update!(user: buyer)

        post v1_market_buy_path(item), headers: authorized_headers(buyer)
        expect(response.status).to eq 422
      end

      it 'transactionの中で例外が発生した場合は422を返し、何もしない' do
        allow_any_instance_of(Item).to receive(:destroy!).and_raise(StandardError)

        post v1_market_buy_path(item), headers: authorized_headers(buyer)
        expect(response.status).to eq 422
      end
    end
  end
end
