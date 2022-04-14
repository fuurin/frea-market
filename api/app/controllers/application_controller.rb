# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  devise_token_auth_group :user, contains: [:v1_user]
end
