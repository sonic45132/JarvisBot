require 'eaal'
require 'date'
require 'psych'

class EveParser

  def initialize
    @api = nil
    puts 'loading eve settings...'
    self.load_settings
  end

  def load_settings
    puts File.expand_path(File.dirname(__FILE__)+'../configs/eve_config.yaml')
    if File.exist? File.dirname(__FILE__)+'../configs/eve_config.yaml'
      settings = Psych.load_file(File.dirname(__FILE__)+'../configs/eve_config.yaml')
      EAAL.cache = EAAL::Cache::FileCache.new
      puts 'Connecting to Eve API...'
      @api = EAAL::API.new(settings['userid'], settings['apikey'])
      puts 'Connected to Eve'
    end
  end

  def setup
    if !File.exist? File.dirname(__FILE__)+'../configs/eve_config.yaml'
      settings = Hash.new()
      print 'Enter api user id: '
      settings['userid'] = gets.chomp
      print 'Enter api key: '
      settings['apikey'] = gets.chomp
      File.open(File.dirname(__FILE__)+'../configs/eve_config.yaml','w') do |file|
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
      skill = look_up(row.typeID)
      diff = DateTime.strptime(row.endTime.to_s, '%F %T').to_time - Time.now
      hours = (diff/ 3600).to_i
      minutes = ((diff % 3600) / 60).to_i
      seconds = ((diff % 3600) % 60).to_i
      rows.push(skill+' '+row.level+' - '+hours.to_s.rjust(2,'0')+':'+minutes.to_s.rjust(2,'0')+':'+seconds.to_s.rjust(2,'0'))
    }
    return rows.join("\n")
  end

  def look_up(id)
    @api.scope = 'eve'
    name = @api.TypeName('ids' => id.to_s).types.first.typeName
    return name.to_s
  end

end

if __FILE__ == $0
  eve = EveParser.new()
  puts eve.parse('eve queue')
  puts eve.parse('nothing at all')
end
