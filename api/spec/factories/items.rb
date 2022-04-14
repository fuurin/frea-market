# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: Item do
    user { create(:user) }
    sequence(:name, 1) { |n| "item_#{n}" }
    sequence(:description, 1) { |n| "description_#{n}" }
    point { 1 }
    sold { false }
  end
end
