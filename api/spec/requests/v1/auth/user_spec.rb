# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Auth::Users', type: :request do
  describe 'GET /v1/auth/user', openapi: {
    summary: 'ログイン中ユーザ情報取得用エンドポイント'
  } do
    it 'ログイン済みならば、ユーザの情報とともに200を返す' do
      user = create(:user)
      get v1_auth_user_path, headers: authorized_headers(user)
      expect(response.status).to eq 200
      res = JSON.parse(response.body)
      expect(res['id']).to eq user.id
      expect(res['name']).to eq user.name
      expect(res['email']).to eq user.email
      expect(res['point']).to eq user.point
    end

    it 'ログインしていなければ401を返す' do
      get v1_auth_user_path
      expect(response.status).to eq 401
    end
  end
end
