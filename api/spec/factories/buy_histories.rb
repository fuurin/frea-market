# frozen_string_literal: true

FactoryBot.define do
  factory :buy_history, class: BuyHistory do
    user { create(:user) }
    item { create(:item) }
  end
end
