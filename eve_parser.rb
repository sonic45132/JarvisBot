require 'eaal'

class EveParser

  def initialize
    @api = nil
    puts 'loading settings...'
    self.load_settings
  end

  def load_settings
    if File.exist? File.dirname(__FILE__)+'/configs/eve_config.yaml'
      settings = Psych.load_file(File.dirname(__FILE__)+'/configs/eve_config.yaml')
      EAAL.cache = EAAL::Cache::FileCache.new
      puts 'Connecting to Eve API...'
      @api = EAAL::API.new(settings['userid'], settings['apikey'])
      puts 'Connect to Eve'
      result = @api.Characters
      result.characters.each{|character|
        puts character.name
      }
    end
  end

  def setup
    if !File.exist? File.dirname(__FILE__)+'/configs/eve_config.yaml'
      settings = Hash.new()
      print 'Enter api user id: '
      settings['userid'] = gets.chomp
      print 'Enter api key: '
      settings['apikey'] = gets.chomp
      File.open(File.dirname(__FILE__)+'/configs/eve_config.yaml','w') do |file|
        file.puts settings.to_yaml
      end
    end
  end

  def parse(msg)
    if msg.downcase == 'eve queue'
      charid = @api.Characters.characters.first.characterID
      @api.scope = 'char'
      return queue = @api.SkillQueue('characterID' => charid).skillqueue
    else
      return nil
    end
  end

end

if __FILE__ == $0
  eve = EveParser.new()
  puts eve.parse('eve queue')
  puts eve.parse('nothing at all')
end