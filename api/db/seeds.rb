# frozen_string_literal: true

users = 3.times.map { FactoryBot.create(:user) }
users.each { |user| 3.times { FactoryBot.create(:item, user: user) } }
