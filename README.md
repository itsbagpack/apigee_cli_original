# ApigeeCli

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'apigee_cli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apigee_cli

## Commands

### Top level commands

    Commands:
      apigee apigeetool [COMMAND]  # Run a command using the apigeetool Node.js module
      apigee config [COMMAND]      # Run a command within the context of an app configuration
      apigee help [COMMAND]        # Describe available commands or one specific command
      apigee settings              # Show the current apigeerc settings
      apigee version               # Shows the Apigee CLI version number

### To see sublevel commands, you can run:

    apigee help apigeetool
    apigee help config

## Usage

### Configuration Settings on Apigee Server

    # Pull down configs for an environment (default is test)
    apigee config pull

    # Pull down configs for a selected environment
    apigee config pull [--environment=staging|-e=staging]

    # Pull down configs for a selected config_name
    apigee config pull --config_name=configuration_one

    # Update config key-value pair (requires config_name)
    apigee config push --config_name=configuration_one key_one=value_one

    # Update config key-value pair (requires config_name) for a selected environment
    apigee config push --config_name=configuration_one key_one=value_one [--environment=staging|-e=staging]

    # Overwrite existing config key-value pair
    apigee config push --config_name=configuration_one --overwrite=true key_one=changed_value_one

    # Delete config key-value pair
    apigee config delete --config_name=configuration_one --entry_name=key_one

    # Delete config for that config_name
    apigee config delete --config_name=configuration_one

## Contributing

1. Fork it ( http://github.com/<my-github-username>/apigee_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
