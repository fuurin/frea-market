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

  describe '削除' do
    it '紐づくitemも同時に削除される' do
      user = create(:user)
      3.times { create(:item, user: user) }
      expect do
        user.destroy!
      end.to change(Item, :count).by(-3)
    end
  end

  describe '#buy!' do
    let!(:buyer) do
      user = create(:user)
      user.update!(point: 1000)
      user
    end
    let!(:seller) do
      user = create(:user)
      user.update!(point: 1000)
      user
    end
    let!(:item) { create(:item, user: seller, point: 500) }

    it '売買処理の実行' do
      history = buyer.buy!(item)

      expect(history).to be_truthy
      expect(history.buyer_id).to eq buyer.id
      expect(history.buyer_point_to).to eq 500
      expect(history.seller_id).to eq seller.id
      expect(history.seller_point_to).to eq 1500
      expect(history.item_id).to eq item.id

      [buyer, seller].each(&:reload)
      expect(buyer.point).to eq 500
      expect(seller.point).to eq 1500
      expect(Item.find_by(id: item.id)).to be_nil
    end

    context '失敗' do
      after do
        expect(MarketHistory.count).to eq 0
        [buyer, seller].each(&:reload)
        expect(buyer.point).to eq 1000
        expect(seller.point).to eq 1000
        expect(Item.find_by(id: item.id)).to be_truthy
      end

      it '購入時のポイントが足りなければ何もせずエラー' do
        item.update!(point: 10_000)
        expect do
          buyer.buy!(item)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'buyerとsellerが同一の場合は何もせずエラー' do
        item.update!(user: buyer)
        expect do
          buyer.buy!(item)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'transactionの中で例外が発生した場合はロールバックする' do
        allow_any_instance_of(Item).to receive(:destroy!).and_raise(StandardError)
        expect do
          buyer.buy!(item)
        end.to raise_error(StandardError)
      end
    end
  end
end
