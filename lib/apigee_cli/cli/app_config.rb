class AppConfig < ThorCli
  namespace 'config'
  default_task :pull

  MAP_KEY   = 'keyValueMap'
  ENTRY_KEY = 'entry'

  desc 'pull', 'Pulls down keyvaluemaps from Apigee server'
  option :config_name, type: :string
  def pull
    config_name = options[:config_name]
    config_set  = ApigeeCli::ConfigSet.new(environment)

    if config_name
      pull_entry(config_set, config_name)
    else
      pull_list(config_set)
    end
  end

  desc 'push', 'Push up keyvaluemaps to Apigee server'
  option :config_name, type: :string
  option :overwrite, type: :boolean, default: false
  def push(*configs)
    config_name = options[:config_name]
    overwrite   = options[:overwrite]

    config_set  = ApigeeCli::ConfigSet.new

    begin
      orig_config_set = Hashie::Mash.new(config_set.read(config_name))
      orig_keys = orig_config_set[ENTRY_KEY].map { |kv| kv[:name] }
    rescue RuntimeError => e
      render_error(e)
      exit
    end

    data = populate_data(orig_keys, configs, overwrite)

    if data.empty?
      say("No keys were changed", :red)
      render_entry(config_name, orig_config_set[ENTRY_KEY])
    else
      update_entry(config_set, config_name, data)
    end
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
        render_entry(config_name, response[ENTRY_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def update_entry(config_set, config_name, data)
      begin
        changed_keys = data.map { |kv| kv[:name] }
        response = Hashie::Mash.new(config_set.update(config_name, data))
        render_entry(config_name, response[ENTRY_KEY], changed_keys)
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def populate_data(orig_keys, configs, overwrite)
      configs.each_with_object([]) do |config, data|
        name  = config.split("=", 2).first
        value = config.split("=", 2).last

        next if !overwrite && orig_keys.include?(name)

        data << { name: name, value: value }
      end
    end

    def render_list(entries)
      entries.each do |entry|
        render_entry(entry['name'], entry[ENTRY_KEY])
      end
    end

    def render_entry(config_name, key_values, highlight = [])
      say("Environment: #{environment}, Config Name: #{config_name}", :blue)
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
