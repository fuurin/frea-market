# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  around_create :set_init_point

  has_many :items, class_name: 'Item', foreign_key: 'user_id', dependent: :destroy
  has_many :buy_histories, class_name: 'MarketHistory', foreign_key: 'buyer_id'
  has_many :sell_histories, class_name: 'MarketHistory', foreign_key: 'seller_id'

  validates :name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i },
            uniqueness: { case_sensitive: true }
  validates :point, presence: true

  def buy!(item)
    ApplicationRecord.transaction do
      item = Item.all.lock.find(item.id)
      buyer, seller = User.all.lock.find(id, item.user_id)
      seller ||= buyer # id == item.user_id の場合sellerがnilになるのでbuyerを入れてappend!で例外を発生させる
      history = MarketHistory.append!(self, seller, item)
      decrement!(:point, item.point)
      seller.increment!(:point, item.point)
      item.destroy!
      return history
    end
  end

  private

  def set_init_point
    self.point = Settings.models.user.init_point
    yield
  end
end
