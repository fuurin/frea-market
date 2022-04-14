# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    sequence(:name, 1) { |n| "user_#{n}" }
    sequence(:email, 1) { |n| "example#{n}@example.com" }
    password { 'password' }
  end
end
