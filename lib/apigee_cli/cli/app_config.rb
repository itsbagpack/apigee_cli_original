class AppConfig < ThorCli
  namespace 'config'
  default_task :pull

  MAP_KEY = 'keyValueMap'

  desc 'pull', 'Pulls down keyvaluemaps from Apigee server'
  option :config_name, type: :string
  def pull
    config_set  = ApigeeCli::ConfigSet.new(environment)
    config_name = options[:config_name]

    if config_name
      pull_entry(config_set, config_name)
    else
      pull_list(config_set)
    end
  end

  desc 'push', 'Push up keyvaluemaps to Apigee server'
  option :config_name, type: :string
  def push(*configs)
    config_set  = ApigeeCli::ConfigSet.new
    config_name = options[:config_name]

    #TODO: compare orig_config_set with configs being passed in... provide option to overwrite...
   #begin
   #  orig_config_set = Hashie::Mash.new(config_set.read(config_name))
   #rescue RuntimeError => e
   #  render_error(e)
   #  exit
   #end

    data = []
    configs.each do |config|
      name  = config.split("=", 2).first
      value = config.split("=", 2).last
      data << { name: name, value: value }
    end

    changed_keys = data.map { |d| d[:name] }

    update_entry(config_set, config_name, data, changed_keys)
  end

  private

    def pull_list(config_set)
      response = Hashie::Mash.new(config_set.all)
      entries = response[MAP_KEY]
      render_list(entries)
    end

    def pull_entry(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.read(config_name))
        render_entry(config_name, response['entry'])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def update_entry(config_set, config_name, data, changed_keys)
      begin
        response = Hashie::Mash.new(config_set.update(config_name, data))
        render_entry(config_name, response['entry'], changed_keys)
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def render_list(entries)
      entries.each do |entry|
        render_entry(entry['name'], entry['entry'])
      end
    end

    def render_entry(entry_name, key_values, highlight = [])
      say("Environment: #{environment}, Config Name: #{entry_name}", :blue)
      key_values.each do |kv|
        name  = kv['name']
        value = kv['value']

        if highlight.include?(name)
          say("\s\s#{name}: #{value}", :yellow)
        else
          say("\s\s#{name}: #{value}", :green)
        end
      end
    end

    def render_error(error)
      say(error, :red)
    end
end
