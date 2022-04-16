# frozen_string_literal: true

class V1::Auth::UserController < ApplicationController
  before_action :authenticate_user!, only: :show

  # GET /v1/auth/user
  def show
    render json: current_user
  end
end
