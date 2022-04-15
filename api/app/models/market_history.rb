# frozen_string_literal: true

class MarketHistory < ApplicationRecord
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :item, class_name: 'Item', foreign_key: 'item_id'

  validates :buyer_name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :buyer_email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i }
  validates :seller_name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :seller_email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i }
  validates :item_name,
            presence: true,
            length: { minimum: Settings.models.item.name_length.min, maximum: Settings.models.item.name_length.max }
  validates :item_description, length: { maximum: Settings.models.item.name_length.max }
  validates :item_point, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :validate_buyer_is_not_seller

  class << self
    def append!(buyer, seller, item)
      create!(
        buyer_id: buyer.id,
        buyer_name: buyer.name,
        buyer_email: buyer.email,
        seller_id: seller.id,
        seller_name: seller.name,
        seller_email: seller.email,
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

    errors.add(:base, I18n.t('models.errors.market_history.buyer_is_seller_error'))
  end
end
