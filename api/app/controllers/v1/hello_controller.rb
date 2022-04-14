# frozen_string_literal: true

class V1::HelloController < ApplicationController
  before_action :authenticate_user!, only: :show

  def index
    render json: { message: 'Hello' }.to_json
  end

  def show
    render json: { message: "Hello #{current_user.name}" }.to_json
  end
end
