require 'eaal'

class EveParser

  def initialize
    @api = nil
    load_settings
  end

  def load_settings
    if File.exist? File.dirname(__FILE__)+'/configs/eve_config.yaml'
      settings = Psych.load_file(File.dirname(__FILE__)+'/config.yaml')
      EAAL.cache = EAAL::Cache::FileCache.new
      @api = EAAL::API.new(settings['userid'], settings['apikey'])
    end
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
    charid = @api.Characters.characters.first.characterID
    api.scope = 'char'
    return queue = api.SkillQueue('characterID' => charid).skillqueue
  end

end