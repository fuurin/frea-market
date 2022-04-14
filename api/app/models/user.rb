# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  around_create :set_init_point

  validates :name,
            presence: true,
            length: { minimum: Settings.models.user.name_length.min, maximum: Settings.models.user.name_length.max }
  validates :email,
            presence: true,
            format: { with: /#{Settings.models.user.email_format_regex}/i },
            uniqueness: { case_sensitive: true }
  validates :point, presence: true

  def set_init_point
    self.point = Settings.models.user.init_point
    yield
  end
end
