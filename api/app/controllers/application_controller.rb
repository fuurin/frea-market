# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  devise_token_auth_group :user, contains: [:v1_user]
  delegate :t, to: I18n

  def render_not_found
    render status: 404, json: { errors: [t('api.errors.not_found')] }
  end

  def render_bad_request(message = t('api.errors.bad_request'))
    render status: 400, json: { errors: [*message] }
  end
end
