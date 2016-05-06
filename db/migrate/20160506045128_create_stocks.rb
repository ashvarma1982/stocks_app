class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :ticker
      t.string :name
      t.decimal :open_price
      t.decimal :close_price

      t.timestamps null: false
    end
  end
end
