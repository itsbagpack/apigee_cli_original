require 'thor'

module ApigeeCli
  class Cli < Thor
    desc "version", "Shows the Apigee CLI version number"
    def version
      say ApigeeCli::VERSION
    end

    desc 'settings', 'Show the current apigeerc settings'
    def settings
      puts ApigeeCli.configuration.apigeerc_config.to_yaml
    end

    desc 'config [COMMAND]', 'Run a command within the context of an app configuration'
    subcommand 'config', ::AppConfig

    desc 'apigeetool [COMMAND]', 'Run a command using the apigeetool Node.js module'
    subcommand 'apigeetool', ::ApigeeTool
  end
end
