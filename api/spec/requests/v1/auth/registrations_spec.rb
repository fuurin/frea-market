# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Auth::Registrations', type: :request do
  describe 'POST /v1/auth/sign_up' do
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
end
