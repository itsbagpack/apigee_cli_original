class AppConfig < ThorCli
  namespace 'config'
  default_task :pull

  MAP_KEY = 'keyValueMap'

  desc 'pull', 'Pulls down keyvaluemaps from Apigee server'
  option :config_name, type: :string
  def pull
    config_set = ApigeeCli::ConfigSet.new

    if options[:config_name]
      pull_entry(config_set, options[:config_name])
    else
      pull_list(config_set)
    end
  end

  desc 'push', 'Push up keyvaluemaps to Apigee server'
  option :config_name, type: :string
  def push(*configs)
    config_name = options[:config_name]
    config_set = ApigeeCli::ConfigSet.new
    orig_config_set = Hashie::Mash.new(config_set.read(config_name))

    data = []
    configs.each do |config|
      name  = config.split("=", 2).first
      value = config.split("=", 2).last
      data << { name: name, value: value }
    end

    response = Hashie::Mash.new(config_set.update(config_name, data))
    changed_keys = data.map { |d| d[:name] }
    render_entry(config_name, response['entry'], changed_keys)
  end

  private

    def pull_list(config_set)
      response = Hashie::Mash.new(config_set.all)
      entries = response[MAP_KEY]
      entries.each do |entry|
        render_entry(entry['name'], entry['entry'])
      end
    end

    def pull_entry(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.read(config_name))
        render_entry(config_name, response['entry'])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def render_entry(entry_name, key_values, highlight = [])
      say("Config Name: #{entry_name}", :blue)
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
