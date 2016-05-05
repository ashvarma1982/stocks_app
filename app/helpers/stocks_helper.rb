module StocksHelper
	# constant for the stocks dropdown
	STOCKS = {:aapl =>'Apple',:feye => 'FireEye',:tsla => 'Tesla', :goog => "Google"}
	
	def stock_list
	 arr = [['Select stock','none']]
	 STOCKS.each{|k,v| arr << [v,k.to_s]}
     arr
	end

end
