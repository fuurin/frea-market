# frozen_string_literal: true

class V1::MarketController < ApplicationController
  before_action :authenticate_user!,
                :set_item,
                :set_seller,
                :validate_buyer_point,
                only: :buy

  # GET /v1/market
  def show
    items = Item
            .joins(:user) # sellerがいなければ一覧に入れない
            .order(created_at: :desc)
            .page(params[:page])
            .per(Settings.models.item.page_size)

    # ログイン中ユーザがいれば、ログイン中ユーザ自身の商品は結果に含まない。
    if current_user.present?
      items = items.where.not(user: current_user)
    end

    render json: items
  end

  # POST /v1/market/buy/1
  def buy
    ApplicationRecord.transaction do
      current_user.increment!(:point, @item.point)
      @seller.decrement!(:point, @item.point)
      MarketHistory.append!(current_user, @seller, @item)
      @item.destroy!
    end
  rescue StandardError => e
    render_unprocessable_entity(e.message)
  end

  private

  # 購入する商品が存在しなければ購入できない
  def set_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound => _e
    render_not_found
  end

  # ポイントが足りなければ購入できない
  def validate_buyer_point
    if current_user.point >= @item.point
      return
    end

    render_bad_request(t('api.errors.bad_request_buyer', point: @item.point))
  end
end
