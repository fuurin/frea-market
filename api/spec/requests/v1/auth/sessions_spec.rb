# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Auth::Sessions', type: :request do
  describe 'POST /v1/auth/sign_in', openapi: {
    summary: 'ログイン用エンドポイント'
  } do
    let(:user_params) do
      {
        name: 'example',
        email: 'example@example.com',
        password: 'password',
        confirm_pasword: 'password'
      }
    end

    before do
      # 登録を済ませておく
      post v1_user_registration_path, params: user_params, as: :json
    end

    it 'ログインに成功したら200を返す' do
      post v1_user_session_path, params: { email: user_params[:email], password: user_params[:password] }, as: :json
      expect(response).to have_http_status(200)
    end

    it 'ログインに失敗したら401を返す' do
      post v1_user_session_path, params: { email: 'hoge', password: 'fuga' }, as: :json
      expect(response).to have_http_status(401)
    end
  end
end
