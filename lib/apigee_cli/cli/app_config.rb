require 'apigee_cli/cli/thor_cli'

class AppConfig < ThorCli
  namespace 'config'
  default_task :list

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

  desc 'push', 'Push up keyvaluemaps for [config_name] to Apigee server'
  option :config_name, type: :string, default: ApigeeCli::ConfigSet::DEFAULT_CONFIG_NAME
  option :overwrite, type: :boolean, default: false
  def push(*entries)
    config_name = options[:config_name]
    overwrite   = options[:overwrite] || false

    config_set  = ApigeeCli::ConfigSet.new(environment)

    data = populate_data(entries)
    result, changed_keys = config_set.add_config(config_name, data, overwrite)

    if result == :error
      say "Error [#{changed_keys.first}] pushing config for [#{config_name}] to [#{environment}] environment"
      exit
    end

    if result == :new
      say "Creating new config for [#{config_name}] in [#{environment}] environment"
    elsif result == :existing
      say "Adding new keys #{changed_keys} to config #{config_name} in #{environment} environment"
    elsif result == :overwritten
      say "Overwriting existing config #{config_name} in #{environment} environment"
    end

    updated_config = config_set.read_config(config_name)[ApigeeCli::ConfigSet::ENTRY_KEY]

    render_config(config_name, updated_config, changed_keys)
  end

  desc 'delete', 'Delete keyvaluemaps for [config_name] from Apigee server'
  option :config_name, type: :string, default: ApigeeCli::ConfigSet::DEFAULT_CONFIG_NAME
  option :entry_name, type: :string
  def delete
    config_name = options[:config_name]
    entry_name  = options[:entry_name]

    config_set  = ApigeeCli::ConfigSet.new(environment)

    pull_list(config_set)

    if entry_name
      confirm = yes? "Are you sure you want to delete #{entry_name} from #{config_name} in #{environment} environment? [y/n]"
      return if !confirm

      remove_entry(config_set, config_name, entry_name)
    else
      confirm = yes? "Are you sure you want to delete #{config_name} from #{environment} environment? [y/n]"
      return if !confirm

      remove_config(config_set, config_name)
    end
  end

  private

    def pull_list(config_set)
      begin
        response = Hashie::Mash.new(config_set.list_configs)
        render_list(response[ApigeeCli::ConfigSet::MAP_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def pull_config(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.read_config(config_name))
        render_config(config_name, response[ApigeeCli::ConfigSet::ENTRY_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def remove_config(config_set, config_name)
      begin
        response = Hashie::Mash.new(config_set.remove_config(config_name))
        say "Config #{config_name} has been deleted from #{environment} environment", :red
        render_config(config_name, response[ApigeeCli::ConfigSet::ENTRY_KEY])
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def remove_entry(config_set, config_name, entry_name)
      begin
        response = Hashie::Mash.new(config_set.remove_entry(config_name, entry_name))
        say "Entry #{entry_name} has been deleted from #{config_name} in #{environment} environment", :red
        render_entry(response)
      rescue RuntimeError => e
        render_error(e)
      end
    end

    def populate_data(entries)
      entries.each_with_object([]) do |entry, data|
        name  = entry.split("=", 2).first
        value = entry.split("=", 2).last

        data << Hashie::Mash.new({ name: name, value: value })
      end
    end

    def render_list(configs)
      configs.each do |config|
        render_config(config['name'], config[ApigeeCli::ConfigSet::ENTRY_KEY])
      end
    end

    def render_config(config_name, entries, highlight = [])
      say "Environment: #{environment}, Config Name: #{config_name}", :blue
      entries.each do |entry|
        name  = entry['name']
        color = highlight.include?(name) ? :yellow : :green

        render_entry(entry, color)
      end
    end

    def render_entry(entry, color = :green)
      name  = entry['name']
      value = entry['value']

      say "\s\s#{name}: #{value}", color
    end

    def render_error(error)
      say error.to_s, :red
    end
end
