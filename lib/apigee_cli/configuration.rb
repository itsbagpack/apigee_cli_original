module ApigeeCli
  class << self
    def configuration
      @configuration ||= ApigeeCli::Configuration.new
    end
  end

  class Configuration
    def apigeerc_config
      begin
        @apigeerc_config = YAML.load_file("#{ENV['HOME']}/.apigeerc")
      rescue
        raise "Error loading .apigeerc file"
      end
      @apigeerc_config.merge! local_apigeerc_config
      @apigeerc_config
    end

    def username
      raise 'Not Configured' if apigeerc_config['username'].nil?
      apigeerc_config['username']
    end

    def password
      raise 'Not Configured' if apigeerc_config['password'].nil?
      apigeerc_config['password']
    end

    def org
      raise 'Not Configured' if apigeerc_config['org'].nil?
      apigeerc_config['org']
    end

    def local_apigeerc_config
      File.exists?("./.apigeerc") ? YAML.load_file("./.apigeerc") : {}
    end

    def method_missing(sym, *args, &block)
      apigeerc_config[sym.to_s]
    end
  end
end
