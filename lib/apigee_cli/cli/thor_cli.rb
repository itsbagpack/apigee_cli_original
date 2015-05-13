class ThorCli < Thor
  class_option :environment, aliases: [:env, :e]

  no_commands do
    def environment
      options[:environment] || 'production'
    end
  end
end
