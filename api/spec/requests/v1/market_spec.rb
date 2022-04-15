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
      let(:login_user) { create(:user) }

      it 'ログイン中ユーザ以外によって販売されている商品をページングで取得できる' do
        page_size = Settings.models.item.page_size
        market_items = (page_size + 1).times.map { |i| create(:item, user: users[i % users.size]) }

        5.times { create(:item, user: login_user) }

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
        5.times { create(:item, user: login_user) }
        get v1_market_path, headers: authorized_headers(login_user)
        expect(response.status).to eq 200
        items = JSON.parse(response.body)
        expect(items.size).to eq 6
        expected_items = market_items.filter { |item| item.user_id != deleted_user.id }.map(&:id).sort
        expect(items.map { |item| item['id'] }.sort).to eq expected_items
      end
    end
  end

  # describe 'POST #buy' do
  # end
end
