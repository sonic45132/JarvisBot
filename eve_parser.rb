require 'eaal'
require 'date'

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
      puts 'Connected to Eve'
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
      return get_queue
    else
      return nil
    end
  end

  def get_queue
    @api.scope = 'account'
    charid = @api.Characters.characters.first.characterID
    @api.scope = 'char'
    queue = @api.SkillQueue('characterID' => charid).skillqueue
    rows = Array.new
    queue.each { |row|
      diff = DateTime.strftime(row.endTime.to_s, '%F %T') - DateTime.strftime(row.startTime.to_s, '%F %T')
      time_left = Date.send(:day_fraction_to_time, diff)
      rows.push(time_left)
    }
    return rows.to_s
  end

end

if __FILE__ == $0
  eve = EveParser.new()
  puts eve.parse('eve queue')
  puts eve.parse('nothing at all')
end