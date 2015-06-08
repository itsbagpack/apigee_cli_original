class AppConfig < ThorCli
  namespace 'config'
  default_task :list

  MAP_KEY   = 'keyValueMap'
  ENTRY_KEY = 'entry'
  DEFAULT_CONFIG_NAME = 'configuration'

  desc 'list', 'Pulls down keyvaluemaps from Apigee server'
  option :config_name, type: :string
  def list
    config_name = options[:config_name]
    config_set  = ApigeeCli::ConfigSet.new(environment)

    if config_name
      pull_config(config_set, config_name)
    else
      pull_list(config_set)
    end
  end

  desc 'push', 'Push up keyvaluemaps to Apigee server'
  option :config_name, type: :string, default: DEFAULT_CONFIG_NAME
  option :overwrite, type: :boolean, default: false
  def push(*entries)
    config_name = options[:config_name]
    overwrite   = options[:overwrite] || false

    config_set  = ApigeeCli::ConfigSet.new(environment)

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
  option :config_name, type: :string, default: DEFAULT_CONFIG_NAME
  option :entry_name, type: :string
  def delete
    config_name = options[:config_name]
    entry_name  = options[:entry_name]

    config_set  = ApigeeCli::ConfigSet.new(environment)

    #TODO: invoke read of that config_name before deletion

    if entry_name
      remove_entry(config_set, config_name, entry_name)
    else
      remove_config(config_set, config_name)
    end
  end

  private

    def pull_list(config_set)
      response = Hashie::Mash.new(config_set.list_configs)
      render_list(response[MAP_KEY])
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

    def remove_config(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.remove_config(config_name))
        say("Config #{config_name} has been deleted from #{environment} environment", :red)
        render_config(config_name, response[ENTRY_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def remove_entry(config_set, config_name, entry_name)
      begin
        response = Hashie::Mash.new(config_set.remove_entry(config_name, entry_name))
        say("Entry #{entry_name} has been deleted from #{config_name} in #{environment} environment", :red)
        render_entry(response)
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
        color = highlight.include?(name) ? :yellow : :green

        render_entry(entry, color)
      end
    end

    def render_entry(entry, color = :green)
      name  = entry['name']
      value = entry['value']

      say("\s\s#{name}: #{value}", color)
    end

    def render_error(error)
      say(error, :red)
    end
end
