# frozen_string_literal: true

class MarketHistory < ApplicationRecord
  # belongs_toはcreate時自動でリレーション先のレコードが存在するかをチェックする
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :item, class_name: 'Item', foreign_key: 'item_id'

  validates :buyer_name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :buyer_email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i }
  validates :buyer_point_to, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :seller_name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :seller_email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i }
  validates :seller_point_to, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :item_name,
            presence: true,
            length: { minimum: Settings.models.item.name_length.min, maximum: Settings.models.item.name_length.max }
  validates :item_description, length: { maximum: Settings.models.item.name_length.max }
  validates :item_point, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :validate_buyer_is_not_seller

  class << self
    def append!(buyer, item)
      seller = item.user
      create!(
        buyer_id: buyer.id,
        buyer_name: buyer.name,
        buyer_email: buyer.email,
        buyer_point_to: buyer.point - item.point,
        seller_id: seller.id,
        seller_name: seller.name,
        seller_email: seller.email,
        seller_point_to: seller.point + item.point,
        item_id: item.id,
        item_name: item.name,
        item_description: item.description,
        item_point: item.point
      )
    end
  end

  private

  def validate_buyer_is_not_seller
    if buyer_id != seller_id
      return
    end

    message = I18n.t('activerecord.errors.models.market_history.attributes.buyer_id.buyer_is_not_seller')
    errors.add(:buyer_id, message)
  end
end
