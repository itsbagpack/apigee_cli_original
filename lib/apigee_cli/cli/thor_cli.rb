require 'thor'

class ThorCli < Thor
  class_option :environment, aliases: [:env, :e]

  no_commands do
    def environment
      options[:environment] || 'test'
    end

    def org
      'bellycard'
    end
  end
end
