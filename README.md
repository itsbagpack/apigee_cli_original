# ApigeeCli

An API Wrapper and CLI for Apigee

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
    apigee help resource

## Usage

### Configuration Settings on Apigee Server

## apigee config list

    # List configs for default environment of test
    $ apigee config list

    # List config for a particular config_name in an environment
    $ apigee config list [--environment=staging|-e=staging] [--config_name=configuration_one]

## apigee config push

    # Update config key-value pair (default environment is test, default config_name is configuration)
    $ apigee config push key_one=value_one

    # Overwrite existing config key-value pair
    $ apigee config push key_one=changed_value_one --overwrite=true [--environment=staging|-e=staging] [--config_name=configuration_one]

## apigee config delete

    # Delete config key-value pair (default config_name is configuration)
    $ apigee config delete --entry_name=key_one

    # Delete config for that config_name
    $ apigee config delete --config_name=configuration_one

### Resource Files on Apigee Server

## apigee resource list

[To be filled in]

## apigee resource push

[To be filled in]

## apigee resource delete

[To be filled in]

## Contributing

1. Fork it ( http://github.com/<my-github-username>/apigee_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
