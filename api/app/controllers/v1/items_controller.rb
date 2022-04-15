# frozen_string_literal: true

class V1::ItemsController < ApplicationController
  before_action :authenticate_user!, except: :show
  before_action :set_item, only: :show
  before_action :set_user_item, only: %i[update destroy]

  # GET /v1/items
  def index
    # current_userのitem一覧をページングで取得
    items = Item
            .by_user(current_user)
            .order(created_at: :desc)
            .page(params[:page])
            .per(Settings.models.item.page_size)

    # デフォルトでon_saleのみ、params[:with_sold] == true で全て返す
    items = if params[:with_sold]
              items.all
            else
              items.on_sale
            end

    render json: items
  end

  # GET /v1/items/1
  def show
    render json: @item
  end

  # POST /v1/items
  def create
    new_item = Item.new(item_params!)
    new_item.user = current_user

    if new_item.save
      render json: new_item, status: :created
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  rescue JSON::Schema::ValidationError => e
    render_bad_request(e.message)
  end

  # PATCH/PUT /v1/items/1
  def update
    if @user_item.update(item_params!)
      render json: @user_item
    else
      render json: @user_item.errors, status: :unprocessable_entity
    end
  rescue JSON::Schema::ValidationError => e
    render_bad_request(e.message)
  end

  # DELETE /v1/items/1
  def destroy
    @user_item.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  rescue ActiveRecord::RecordNotFound => _e
    render_not_found
  end

  def set_user_item
    @user_item = Item.by_user(current_user).find(params[:id])
  rescue ActiveRecord::RecordNotFound => _e
    render_not_found
  end

  # Only allow a trusted parameter "white list" through.
  def item_params!
    permit_params = params.require(:item).permit(:name, :description, :point)
    JSON::Validator.validate!(Item.params_schema, permit_params.to_hash)
    permit_params
  end
end
