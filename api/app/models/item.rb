# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'user_id' # seller

  validates :name,
            presence: true,
            length: { minimum: Settings.models.item.name_length.min, maximum: Settings.models.item.name_length.max }
  validates :description, length: { maximum: Settings.models.item.name_length.max }
  validates :point, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :sold, inclusion: [true, false]

  scope :by_user, ->(user) { where(user: user) }

  class << self
    def on_sale
      where(sold: false)
    end

    def params_schema
      @params_schema ||= {
        type: 'object',
        properties: {
          name: {
            type: 'string',
            minLength: Settings.models.item.name_length.min,
            maxLength: Settings.models.item.name_length.max
          },
          description: { type: 'string', maxLength: Settings.models.item.description_length.max },
          point: { type: 'integer', minimum: 1 }
        }
      }
    end
  end
end
