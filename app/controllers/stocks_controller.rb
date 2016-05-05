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
end
