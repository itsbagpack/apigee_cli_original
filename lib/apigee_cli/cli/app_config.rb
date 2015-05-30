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
      pull_config(config_set, config_name)
    else
      pull_list(config_set)
    end
  end

  desc 'push', 'Push up keyvaluemaps to Apigee server'
  option :config_name, type: :string
  option :overwrite, type: :boolean, default: false
  def push(*entries)
    config_name = options[:config_name]
    overwrite   = options[:overwrite]

    config_set  = ApigeeCli::ConfigSet.new

    begin
      orig_config_set = Hashie::Mash.new(config_set.read_config(config_name))
      orig_keys = orig_config_set[ENTRY_KEY].map { |entry| entry[:name] }
    rescue RuntimeError => e
      render_error(e)
      exit
    end

    data = populate_data(orig_keys, entries, overwrite)

    if data.empty?
      say("No keys were changed", :red)
      render_config(config_name, orig_config_set[ENTRY_KEY])
    else
      update_config(config_set, config_name, data)
    end
  end

  desc 'delete', 'Delete keyvaluemaps for [config_name] from Apigee server'
  option :config_name, type: :string, required: true
  option :entry_name, type: :string
  def delete
    config_name = options[:config_name]
    entry_name  = options[:entry_name]

    config_set  = ApigeeCli::ConfigSet.new

    if entry_name
    else
    end
  end

  private

    def pull_list(config_set)
      response = Hashie::Mash.new(config_set.list_configs)
      entries = response[MAP_KEY]
      render_list(entries)
    end

    def pull_config(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.read_config(config_name))
        render_config(config_name, response[ENTRY_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def update_config(config_set, config_name, data)
      begin
        changed_keys = data.map { |kv| kv[:name] }
        response = Hashie::Mash.new(config_set.update_config(config_name, data))
        render_config(config_name, response[ENTRY_KEY], changed_keys)
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def populate_data(orig_keys, entries, overwrite)
      entries.each_with_object([]) do |entry, data|
        name  = entry.split("=", 2).first
        value = entry.split("=", 2).last

        next if !overwrite && orig_keys.include?(name)

        data << { name: name, value: value }
      end
    end

    def render_list(configs)
      configs.each do |config|
        render_config(config['name'], config[ENTRY_KEY])
      end
    end

    def render_config(config_name, entries, highlight = [])
      say("Environment: #{environment}, Config Name: #{config_name}", :blue)
      entries.each do |entry|
        name  = entry['name']
        value = entry['value']

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
