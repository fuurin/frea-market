# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe '作成' do
    it '成功' do
      expect(create(:item)).to be_truthy
    end

    context '失敗' do
      it 'nameの長さが不正だとエラー' do
        expect do
          create(:item, name: 'a' * (Settings.models.item.name_length.min - 1))
        end.to raise_error ActiveRecord::RecordInvalid

        expect do
          create(:item, name: 'a' * (Settings.models.item.name_length.max + 1))
        end.to raise_error ActiveRecord::RecordInvalid
      end

      it 'descriptionの長さが不正だとエラー' do
        expect do
          create(:item, description: 'a' * (Settings.models.item.description_length.max + 1))
        end.to raise_error ActiveRecord::RecordInvalid
      end

      it 'pointが0以下だとエラー' do
        expect do
          create(:item, point: 0)
        end.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
