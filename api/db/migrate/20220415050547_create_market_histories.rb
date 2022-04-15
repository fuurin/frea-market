# frozen_string_literal: true

class CreateMarketHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :market_histories do |t|
      t.references :buyer, null: false, foreign_key: false, table_to: :user
      t.string :buyer_name, null: false
      t.string :buyer_email, null: false
      t.integer :buyer_point_to, null: false
      t.references :seller, null: false, foreign_key: false, table_to: :user
      t.string :seller_name, null: false
      t.string :seller_email, null: false
      t.integer :seller_point_to, null: false
      t.references :item, null: false, foreign_key: false
      t.string :item_name, null: false
      t.string :item_description
      t.integer :item_point, null: false

      t.timestamps
    end
    add_index :market_histories, %i[buyer_id created_at]
    add_index :market_histories, %i[seller_id created_at]
  end
end
