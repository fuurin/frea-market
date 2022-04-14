# frozen_string_literal: true

class V1::MarketController < ApplicationController
  before_action :authenticate_user!, only: :create

  # GET /v1/market
  def show
    # user以外のitem一覧。userがnilなら全itemを返す
    # デフォルトでon_saleのみ、params[:only_on_sale] == false で
  end

  # POST /v1/market/buy/1
  def buy
    # 購入
    # ポイントが足りなければ購入できない
    # transactionを使う
    #   itemをsoldにする
    #   購入者と販売者のポイントを更新する
    #   historyを作成する
  end
end
