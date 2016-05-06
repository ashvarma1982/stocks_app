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
    @message = "Hello, how are you today?(Stocks are from the Local Stocks DB...)"
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

  def load_db
    render :json => Stock.populate_db
  end

  def empty_db
    render :json => Stock.clear_db
  end


end
