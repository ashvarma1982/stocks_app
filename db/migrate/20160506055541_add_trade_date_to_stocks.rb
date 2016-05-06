class AddTradeDateToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :trade_date, :date
  end
end
