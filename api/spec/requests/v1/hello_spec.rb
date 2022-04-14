# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Hello', type: :request do
  describe 'GET /v1/hello' do
    it 'Helloを返す' do
      get v1_hello_index_path
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['message']).to eq 'Hello'
    end
  end

  describe 'GET /v1/hello/1' do
    it '非ログイン状態では401を返す' do
      get v1_hello_path(1)
      expect(response).to have_http_status(401)
    end

    it 'ログイン状態では200でHello {name}を返す' do
      user = create(:user)
      get v1_hello_path(1), headers: authorized_headers(user)
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['message']).to eq "Hello #{user.name}"
    end
  end
end
