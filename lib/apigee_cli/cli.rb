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
  end
end
