# frozen_string_literal: true

class V1::MarketController < ApplicationController
  before_action :authenticate_user!, :set_item, only: :buy

  # GET /v1/market
  def show
    items = Item
            .order(created_at: :desc)
            .page(params[:page])
            .per(Settings.models.item.page_size)

    # ログイン中ユーザがいれば、ログイン中ユーザ自身の商品は結果に含まない。
    if user_signed_in?
      items = items.where.not(user: current_user)
    end

    render json: items
  end

  # POST /v1/market/buy/1
  def buy
    history = current_user.buy!(@item)
    render status: 201, json: history
  rescue StandardError => e
    render_unprocessable_entity(e.message)
  end

  private

  # 購入する商品が存在しなければ購入できない
  def set_item
    @item = Item.find(params[:item_id])
  rescue ActiveRecord::RecordNotFound => _e
    render_not_found
  end
end
