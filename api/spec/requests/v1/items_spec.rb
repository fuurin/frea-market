# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/v1/items', type: :request do
  let!(:user) { create(:user) }

  describe 'GET #index' do
    it 'ログインしているユーザの販売中の商品をページングで取得できる' do
      page_size = Settings.models.item.page_size
      user_items = (page_size + 1).times.map { create(:item, user: user) }
      another_user = create(:user)
      3.times.map { create(:item, user: another_user) }

      get v1_items_path, headers: authorized_headers(user)
      expect(response.status).to eq 200
      items = JSON.parse(response.body)
      expect(items.size).to eq page_size
      expect(items.map { |item| item['id'] }.sort).to eq user_items.last(page_size).map(&:id).sort

      get v1_items_path, params: { page: 2 }, headers: authorized_headers(user)
      expect(response.status).to eq 200
      items = JSON.parse(response.body)
      expect(items.size).to eq 1
      expect(items.first['id']).to eq user_items.first.id
    end

    it '1つも商品がなかったときでも200を返す' do
      get v1_items_path, headers: authorized_headers(user)
      expect(response.status).to eq 200
      items = JSON.parse(response.body)
      expect(items.size).to eq 0
    end

    it 'ログインしていなければ401を返す' do
      get v1_items_path
      expect(response.status).to eq 401
    end
  end

  describe 'GET #show' do
    let(:item) { create(:item, user: user) }

    it 'idに対する商品のデータがあれば200で返す' do
      get v1_item_path(item)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['id']).to eq item.id
    end

    it 'idに対する商品のデータが存在しなければ404を返す' do
      get v1_item_path(id: 0)
      expect(response.status).to eq 404
    end
  end

  describe 'POST #create' do
    let(:valid_item_params) { { name: 'item_a', description: 'description_a', point: 100 } }

    it '新規作成に成功' do
      expect do
        post v1_items_path, params: { item: valid_item_params }, headers: authorized_headers(user), as: :json
      end.to change(Item.by_user(user), :count).by(1)
      expect(response.status).to eq 201
      expect(user.items.pluck(:id)).to include JSON.parse(response.body)['id']
    end

    it 'リクエストパラメータの検証で失敗すると何もせず400を返す' do
      invalid_item_params = valid_item_params
      invalid_item_params[:point] = 0
      expect do
        post v1_items_path, params: { item: invalid_item_params }, headers: authorized_headers(user), as: :json
      end.not_to change(Item, :count)
      expect(response.status).to eq 400
    end

    it 'ログインしていなければ何もせず401を返す' do
      expect do
        post v1_items_path, params: { item: valid_item_params }, as: :json
      end.not_to change(Item, :count)
      expect(response.status).to eq 401
    end

    it '保存に失敗すると何もせず422を返す' do
      allow_any_instance_of(Item).to receive(:save).and_return(false)
      expect do
        post v1_items_path, params: { item: valid_item_params }, headers: authorized_headers(user), as: :json
      end.not_to change(Item, :count)
      expect(response.status).to eq 422
    end
  end

  describe 'PATCH #update' do
    let!(:item_to_update) { create(:item, user: user, name: 'item_a', description: 'description_a', point: 100) }
    let(:valid_item_params) { { name: 'item_b', description: 'description_b', point: 200 } }

    it '更新に成功' do
      patch v1_item_path(item_to_update), params: { item: valid_item_params }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 200
      item_to_update.reload
      expect(item_to_update.name).to eq valid_item_params[:name]
      expect(item_to_update.description).to eq valid_item_params[:description]
      expect(item_to_update.point).to eq valid_item_params[:point]
    end

    it 'リクエストパラメータの検証で失敗すると何もせず400を返す' do
      invalid_item_params = valid_item_params
      invalid_item_params[:point] = 0
      patch v1_item_path(item_to_update), params: { item: invalid_item_params }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 400
    end

    it 'ログインしていなければ何もせず401を返す' do
      patch v1_item_path(item_to_update), params: { item: valid_item_params }, as: :json
      expect(response.status).to eq 401
    end

    it '保存に失敗すると何もせず422を返す' do
      allow_any_instance_of(Item).to receive(:save).and_return(false)
      patch v1_item_path(item_to_update), params: { item: valid_item_params }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 422
    end
  end

  describe 'DELETE #destroy' do
    let!(:item) { create(:item, user: user) }

    it 'idに対する商品のデータがあれば削除して204を返す' do
      expect do
        delete v1_item_path(item), headers: authorized_headers(user)
      end.to change(Item.by_user(user), :count).by(-1)
      expect(response.status).to eq 204
    end

    it 'ログインしていなければ何もせず401を返す' do
      expect do
        delete v1_item_path(id: 0)
      end.not_to change(Item.by_user(user), :count)
      expect(response.status).to eq 401
    end

    it 'idに対する商品のデータが存在しなければ何もせず404を返す' do
      expect do
        delete v1_item_path(id: 0), headers: authorized_headers(user)
      end.not_to change(Item.by_user(user), :count)
      expect(response.status).to eq 404
    end

    it 'idに対する商品が存在しても、ログイン中のユーザのものでなければ何もせず404を返す' do
      expect do
        delete v1_item_path(item), headers: authorized_headers
      end.not_to change(Item.by_user(user), :count)
      expect(response.status).to eq 404
    end
  end
end
