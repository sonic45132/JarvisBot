require_relative 'parsers/settings_parser'
require_relative 'parsers/mt_gox_parser'
require_relative 'parsers/trade_parser'
require_relative 'parsers/eve_parser'
require 'xmpp4r-simple'
require 'io/console'
require 'psych'

CONFIG_PATH = File.dirname(__FILE__)+'/configs/'

class Jarvis

  def initialize
    @im = nil
    @parsers = Array.new(0)
  end

  def read_settings
    settings = Psych.load_file(File.dirname(__FILE__)+'/config.yaml')
    @alertee = settings['alertee']
    puts 'Setting up parsers...'
    settings['parsers'].each {|parser| @parsers.push(Object.const_get(parser).new(CONFIG_PATH))}
    puts 'Parsers Loaded.'
    puts 'Connecting...'
    @im = Jabber::Simple.new(settings['imuser'],settings['impass'])
    puts 'Connected.'
    @im.deliver(@alertee,'Jarvis bot now online. Waiting for your order.')
  end

  def run
    if @im.received_messages?
      @im.received_messages { |msg|
        parse_message(msg)
      }
    end
  end

  def shutdown
    @im.deliver(@alertee,'Shutting down... Goodbye.')
    @parsers.each { |parser| parser.shutdown if parser.respond_to? :shutdown}
    sleep 1
    @im.disconnect
  end

  def parse_message(msg)
    responces = Array.new(0)
    @parsers.each { |parser|
      response = parser.parse(msg.body)
      responces.push(parser.class.name+': '+response.to_s) unless response == nil
    }
    puts responces
    @im.deliver(@alertee,create_response(responces)) if responces.any?
    puts msg.body if msg.type == :chat
  end

  def create_response(responces)
    resp_string = String.new
    responces.each { |responce|
      resp_string << (responce.to_s<<"\n")
    }
    return resp_string.chomp
  end

end

if __FILE__ == $0

  parsers = %w(TradeParser MtGoxParser EveParser SettingsParser)

  if !File.exist? File.dirname(__FILE__)+'/config.yaml'
    settings = Hash.new
    print 'Enter XMPP username: '
    settings['imuser'] = gets.chomp
    print 'Enter XMPP password: '
    settings['impass'] = gets.chomp
    print 'Enter XMPP user to be alerted: '
    settings['alertee'] = gets.chomp
    puts 'Enter each parser you want to use. Enter it on one line with spaces.'
    print parsers
    settings['parsers'] = gets.chomp.split

    Dir.mkdir('configs') unless File.directory?('configs')

    parsers = Array.new
    settings['parsers'].each {|parser| parsers.push(Object.const_get(parser).new(CONFIG_PATH))}
    parsers.each { |parser| parser.setup if parser.respond_to? :setup}

    File.open(File.dirname(__FILE__)+'/config.yaml','w') do |file|
      file.puts settings.to_yaml
    end

  end

  jarvis = Jarvis.new
  jarvis.read_settings()
  thread_exit = false
  chat_thread = Thread.new {
    while !thread_exit do
      jarvis.run
      sleep 0.75
    end
    jarvis.shutdown()
  }

  input = ''
  while input != 'exit'
    input = gets().chomp()
  end
  thread_exit = true
  chat_thread.join

end

