# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  around_create :set_init_point

  has_many :items, class_name: 'Item', foreign_key: 'user_id', dependent: :destroy

  validates :name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i },
            uniqueness: { case_sensitive: true }
  validates :point, presence: true

  private

  def set_init_point
    self.point = Settings.models.user.init_point
    yield
  end
end
