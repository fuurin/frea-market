# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.integer :point, null: false, default: 1

      t.timestamps
    end

    add_index :items, :name
    add_index :items, :point
    add_index :items, %i[user_id created_at]
  end
end
