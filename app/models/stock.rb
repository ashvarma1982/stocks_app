class Stock < ActiveRecord::Base
	STOCKS_MAP = {
		'aapl' => 'Apple Inc',
		'nflx' => 'Netflix Inc',
		'lnkd' => 'Linked Inc',
		 'ttm' => 'Tata Motors'
	}
	
	def self.populate_db
	  # This method populates the Stocks DB with last 30 day of stock data
	    begin
		  yahoo_client = YahooFinance::Client.new
		  Rails.logger.info  "==Stocks::populate_stocks_db =="
	      STOCKS_MAP.keys.each do |stock_symbol|
	      	get_stocks_info = yahoo_client.historical_quotes(stock_symbol, { start_date: Time::now-(24*60*60*4), end_date: Time::now })
	        Rails.logger.info "==#{stock_symbol}===#{get_stocks_info}=="
		    get_stocks_info.each do |info|
		       insert_new(:ticker => info.symbol,:name => STOCKS_MAP[info.symbol], :close_price => info.close, :open_price => info.open, :trade_date => info.trade_date)
		    end
	    end
	    rescue Exception => e
		   	Rails.logger.info "=========Exception #{e.inspect} in Stock::populate_stocks_db"
	        return false 
        end
    end

    def self.clear_db
       begin
           delete_all
       rescue
       	   Rails.logger.info "=========Exception #{e.inspect} in Stock::clear_stocks_db"
	       return false 
       end
    end



    def self.insert_new(options )
      logger.info "========: Stock::insert_new: === options === #{options.inspect}"
      stock = Stock.where({:ticker =>options[:ticker],:trade_date => options[:trade_date]}).present?
      unless stock.present?
	    Rails.logger.info "========: Stock::insert_new: LOAD NEW STOCK"
	    new_stock = Stock.new( options )
	    if new_stock.valid?
	       val = new_stock.save
	       Rails.logger.info "========: Stock::insert_new: saved? #{val ? 'SAVED' : 'NOT SAVED - this is BAD'}"
	       Rails.logger.info "========: Stock::insert_new: new_stock.errors = #{new_stock.errors.inspect}" if !val
	       return new_stock
	    else
	       logger.info "========: Stock::insert_new: new_stock is NOT valid: NOT SAVED - this is BAD"
	       logger.info "========: Stock::insert_new: new_stock.errors = #{new_stock.errors.inspect}"
	    end
      end
      false
    end

end
