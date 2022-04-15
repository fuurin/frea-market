# frozen_string_literal: true

class BuyHistory < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'user_id' # buyer
  belongs_to :item, class_name: 'Item', foreign_key: 'item_id'
end
