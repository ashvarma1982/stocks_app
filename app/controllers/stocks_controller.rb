class StocksController < ApplicationController
  def list
  	@message = "Hello, how are you today?"
  end

  def show
  	#stocks_info = StockQuote::Stock.quote([params[:stock].to_s, 1.week.from_now, Time.now],['Ask'])
  	@yahoo_client ||= YahooFinance::Client.new
  	data = @yahoo_client.historical_quotes(params[:stock].to_s, { start_date: Time::now-(24*60*60*30), end_date: Time::now }).map(&:close).map(&:to_f)
  	#Rails.logger.info stocks_info.inspect
  	#Rails.logger.info "====data==#{data}=="
  	render :json => {price: data}
  end

  def list_from_db
    @message = "Hello, how are you today?"
  end

  def show_from_db
    data = {}
    dates = []
    close_prices =[]
    open_prices=[]
    data[:stock] = params[:stock].to_s
    stocks = Stock.where(ticker: data[:stock])
    stocks.each do |stock|
       dates.push(stock.trade_date)
       close_prices.push(stock.close_price.to_f)
       open_prices.push(stock.open_price.to_f)
    end
    data[:dates] = dates
    data[:close_prices] = close_prices
    data[:open_prices] = open_prices

    render :json => {data: data}
  end

  def add_or_get_stock_item

    data = {}
    dates = []
    close_prices =[]
    open_prices=[]
    data[:stock] = params[:stock].to_s
    @yahoo_client ||= YahooFinance::Client.new
    @yahoo_client.historical_quotes(data[:stock], { start_date: Time::now-(24*60*60*30), end_date: Time::now }).each do |stock|
      s = Stock.where(ticker: data[:stock], trade_date: stock.trade_date)[0]
      Rails.logger.info "=====s===#{s.inspect}==="
      if (s.present?)
        Rails.logger.info "===get stock info in DB==stock====#{s.inspect}"
        open_prices.push(s.open_price.to_f)
        close_prices.push(s.close_price.to_f) 
        dates.push(s.trade_date)
      else 
        new_stock = Stock.new(ticker: data[:stock],name: Stock::STOCKS_MAP[data[:stock]],trade_date: stock.trade_date, open_price: stock.open, close_price: stock.close)
        if new_stock.valid?
           val = new_stock.save
           Rails.logger.info "========: stock saved? #{val ? 'SAVED' : 'NOT SAVED - this is BAD'}"
           Rails.logger.info "========: new_stock.errors = #{new_stock.errors.inspect}" if !val
           open_prices.push(stock.open.to_f)
           close_prices.push(stock.close.to_f)
           dates.push(stock.trade_date)
        else
           Rails.logger.info "========: new_stock is NOT valid: NOT SAVED - this is BAD"
           Rails.logger.info "========: new_stock.errors = #{new_stock.errors.inspect}"
        end
      end
    end

    data[:dates] = dates
    data[:close_prices] = close_prices
    data[:open_prices] = open_prices
    Rails.logger.info "data====#{data}====="
    render :json => {data: data}
  end


  def load_db
    render :json => Stock.populate_db
  end

  def empty_db
    render :json => Stock.clear_db
  end


end
