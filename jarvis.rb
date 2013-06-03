require 'xmpp4r-simple'
require 'class_loader'
require 'io/console'
require 'psych'

class Jarvis

  def initialize
    @im = nil
    @parsers = Array.new
    test = TradeParser.new
  end

  def read_settings
    settings = Psych.load_file(File.dirname(__FILE__)+'/config.yaml')
    @alertee = settings['alertee']
    puts 'Setting up parsers...'
    settings['parsers'].each {|parser| @parsers.push(Object.const_get(parser).new)}
    puts 'Parsers Loaded.'
    puts @parsers
    puts 'Connecting...'
    @im = Jabber::Simple.new(settings['imuser'],settings['impass'])
    puts 'Connected.'
  end

  def run

    if @im.received_messages?
      @im.received_messages { |msg|
        parse_message(msg)
      }
    end
  end

  def clean_up
    @im.disconnect
  end

  def parse_message(msg)
    puts msg.body if msg.type == :chat
  end

end

if __FILE__ == $0

  parsers = %w(TradeParser MtGoxParser SettingsParser)

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

    File.open(File.dirname(__FILE__)+'/config.yaml','w') do |file|
      file.puts settings.to_yaml
    end

  end

  jarvis = Jarvis.new
  jarvis.read_settings
  thread_exit = false
  chat_thread = Thread.new {
    while !thread_exit do
      jarvis.run
      sleep 1.5
    end
    jarvis.clean_up()
  }

  input = ''
  while input != 'exit'
    input = gets().chomp()
  end
  thread_exit = true
  chat_thread.join

end

