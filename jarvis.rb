require 'xmpp4r-simple'
require 'io/console'
require 'psych'

class Jarvis

  def initialize
    @im = nil
  end

  def read_settings
    settings = Psych.load_file(File.dirname(__FILE__)+'/config.yaml')
    puts 'Connecting...'
    @im = Jabber::Simple.new(settings['imuser'],settings['impass'])
    puts 'Connected.'
  end

  def run
    exit = false
    if @im.received_messages?
      @im.received_messages { |msg|
        exit = parse_message(msg)
      }
    end
    return exit
  end

  def clean_up
    @im.disconnect
  end

  def parse_message(msg)
    puts msg.body if msg.type == :chat
    return true if msg.body.downcase == 'exit'
  end

end

if __FILE__ == $0

  if !File.exist? File.dirname(__FILE__)+'/config.yaml'
    settings = Hash.new
    print 'Enter XMPP username: '
    settings['imuser'] = gets.chomp
    print 'Enter XMPP password: '
    settings['impass'] = gets.chomp

    File.open(File.dirname(__FILE__)+'/config.yaml','w') do |file|
      file.puts settings.to_yaml
    end

  end

  jarvis = Jarvis.new
  jarvis.read_settings
  thread_exit = false
  chat_thread = Thread.new {
    while !thread_exit do
      break if jarvis.run()
      sleep 1.5
    end
    thread_exit = true
    jarvis.clean_up()
  }

  input = ''
  while input != 'exit' && !thread_exit
    input = gets().chomp()
  end
  thread_exit = true
  chat_thread.join

end

