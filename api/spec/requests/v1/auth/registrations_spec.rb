# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Auth::Registrations', type: :request do
  describe 'POST /v1/auth/sign_up', openapi: {
    summary: 'ユーザ登録用エンドポイント'
  } do
    let(:valid_params) do
      {
        name: 'example',
        email: 'example@example.com',
        password: 'password',
        confirm_pasword: 'password'
      }
    end

    it 'ユーザ登録に成功すると200を返す' do
      post v1_user_registration_path, params: valid_params, as: :json
      expect(response.status).to eq 200
      user = User.first
      expect(user.name).to eq valid_params[:name]
      expect(user.email).to eq valid_params[:email]
      expect(user.point).to eq Settings.models.user.init_point
    end

    context '失敗' do
      def check_invalid_registration(invalid_params)
        post v1_user_registration_path, params: invalid_params, as: :json
        expect(response.status).to eq 422
        expect(User.count).to eq 0
      end

      it '必須パラメータが欠けていたら422を返す' do
        %i[name email password confirm_password].each do |param|
          invalid_params = valid_params
          invalid_params.delete(param)
          check_invalid_registration(invalid_params)
        end
      end

      it 'nameの長さが不正だったら422を返す' do
        invalid_params = valid_params
        invalid_params[:name] = 'a' * (Settings.models.user.name_length.min - 1)
        check_invalid_registration(invalid_params)

        invalid_params = valid_params
        invalid_params[:name] = 'a' * (Settings.models.user.name_length.max + 1)
        check_invalid_registration(invalid_params)
      end

      it 'emailの形式が不正だったら422を返す' do
        invalid_params = valid_params
        invalid_params[:email] = 'hoge'
        check_invalid_registration(invalid_params)
      end

      it 'emailが重複したら422を返す' do
        post v1_user_registration_path, params: valid_params, as: :json

        invalid_params = valid_params
        invalid_params[:name] = 'example2'
        post v1_user_registration_path, params: invalid_params, as: :json
        expect(response.status).to eq 422
        expect(User.count).to eq 1
      end
    end
  end

  describe 'PATCH v1_user_registration_path', openapi: {
    summary: 'ユーザ情報編集用エンドポイント'
  } do
    let!(:user) { create(:user, name: 'hoge', email: 'example@example.com') }

    it 'ユーザ情報の編集に成功すると200を返す' do
      patch v1_user_registration_path, params: { name: 'fuga' }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 200
      user.reload
      expect(user.name).to eq 'fuga'

      patch v1_user_registration_path, params: { email: 'piyo@example.com' }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 200
      user.reload
      expect(user.email).to eq 'piyo@example.com'
    end

    it 'ログインしていなければ404を返す' do
      patch v1_user_registration_path, params: { name: 'fuga' }, as: :json
      expect(response.status).to eq 404
    end

    it '編集したemailが重複する場合は編集できず422を返す' do
      create(:user, email: 'hoge@example.com')

      patch v1_user_registration_path, params: { email: 'hoge@example.com' }, headers: authorized_headers(user), as: :json
      expect(response.status).to eq 422
    end
  end

  describe 'PATCH v1_user_password_path', openapi: {
    summary: 'ユーザパスワード変更用エンドポイント',
    tags: %w[V1::Auth::Password]
  } do
    let!(:user) { create(:user) }

    it 'パスワードの編集に成功すると200を返し、そのパスワードでログインできる' do
      patch v1_user_password_path,
            params: { password: 'new_password', password_confirmation: 'new_password' },
            headers: authorized_headers(user),
            as: :json
      expect(response.status).to eq 200

      post v1_user_session_path, params: { email: user.email, password: 'new_password' }, as: :json
      expect(response.status).to eq 200
    end

    it 'ログインしていなければ404を返す' do
      patch v1_user_password_path, params: { password: 'new_password', password_confirmation: 'new_password' }, as: :json
      expect(response.status).to eq 401
    end
  end

  describe 'DELETE v1_user_registration_path', openapi: {
    summary: 'ユーザ削除用エンドポイント'
  } do
    let!(:user) { create(:user) }

    it 'ユーザの削除に成功すると200を返す' do
      delete v1_user_registration_path, headers: authorized_headers(user)
      expect(response.status).to eq 200
      expect(User.find_by(id: user.id)).to be_nil
    end

    it 'ログインしていなければ404を返す' do
      delete v1_user_registration_path
      expect(response.status).to eq 404
    end
  end
end
