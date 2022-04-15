# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuyHistory, type: :model do
  it '作成できる' do
    expect(create(:buy_history)).to be_truthy
  end
end
