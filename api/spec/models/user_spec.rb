# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '作成' do
    context '成功' do
      it '作成できる' do
        expect(create(:user)).to be_truthy
      end

      it '新規登録時の初回ポイント' do
        expect(create(:user).point).to eq Settings.models.user.init_point
      end
    end

    context '失敗' do
      it 'nameの長さが不正だとエラー' do
        expect do
          create(:user, name: 'a' * (Settings.models.user.name_length.min - 1))
        end.to raise_error ActiveRecord::RecordInvalid

        expect do
          create(:user, name: 'a' * (Settings.models.user.name_length.max + 1))
        end.to raise_error ActiveRecord::RecordInvalid
      end

      it 'emailの形式が不正だとエラー' do
        expect do
          create(:user, email: 'hoge')
        end.to raise_error ActiveRecord::RecordInvalid
      end

      it 'emailが重複するユーザを作成しようとするとエラー' do
        email = 'example@example.com'
        create(:user, email: email)
        expect do
          create(:user, email: email)
        end.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end
