# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  devise_token_auth_group :user, contains: [:v1_user]
  delegate :t, to: I18n

  def render_bad_request(message = t('api.errors.bad_request'))
    render status: 400, json: { errors: [*message] }
  end

  def render_forbidden(message = t('api.errors.forbidden'))
    render status: 403, json: { errors: [*message] }
  end

  def render_not_found(message = t('api.errors.not_found'))
    render status: 404, json: { errors: [*message] }
  end

  def render_unprocessable_entity(message = t('api.errors.unprocessable_entity'))
    render status: 422, json: { errors: [*message] }
  end
end
