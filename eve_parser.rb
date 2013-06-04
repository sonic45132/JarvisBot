require 'eaal'

class EveParser

  def initialize
    @api = nil
    load_settings
  end

  def load_settings
    settings = Psych.load_file(File.dirname(__FILE__)+'/config.yaml')
    @api = EAAL::API.new(settings['userid'], settings['apikey'])
  end

  def setup
    puts File.dirname(__FILE__)+'/configs/eve_config.yaml'
    if !File.exist? File.dirname(__FILE__)+'/configs/eve_config.yaml'
      settings = Hash.new()
      print 'Enter api user id: '
      settings['userid'] = gets.chomp
      print 'Enter api key: '
      settings['apikey'] = gets.chomp
      File.open(File.dirname(__FILE__)+'/configs/eve_config','w') do |file|
        file.puts settings.to_yaml
      end
    end
  end

  def parse(msg)
    return 'o/'
  end

end