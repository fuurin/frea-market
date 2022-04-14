# frozen_string_literal: true

class V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController
  def sign_up_params
    params.permit(*params_for_resource(:sign_up), :name)
  end
end
