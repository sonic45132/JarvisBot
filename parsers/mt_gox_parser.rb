require 'net/http'
require 'json'
require 'uri'

class MtGoxParser

  def initialize

  end

  def setup

  end

  def parse(msg)
    if msg.downcase == 'bitcoin price'
      return get_price
    else
      return nil
    end
  end

  def get_price
    uri = URI('http://data.mtgox.com/api/2/BTCUSD/money/ticker_fast')
    result =  JSON.parse(send_data(uri))
    if result['result'] != 'success'
      puts 'Could not get ticker data'
      return nil
    end
    ticker = Hash.new
    ticker['bid'] = result['data']['buy']['value'].to_f
    ticker['ask'] = result['data']['sell']['value'].to_f
    return ticker.to_s
  end

  def send_data(uri)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.read_timeout = 240

      req = Net::HTTP::Get.new(uri.request_uri)
      
      req['User-Agent'] = 'Mozilla/5.0 (compatible; Ruby XMPP Platform)'

      http.request(req)
    end

    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return res.body
      else
        puts res.value
        return nil
    end

  end

end
