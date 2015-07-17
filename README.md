# ApigeeCli

An API Wrapper and CLI for Apigee

## Installation

Add this line to your application's Gemfile:

    gem 'apigee_cli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apigee_cli

## Setting up your User Credentials

Assuming you have an Apigee account, set your user credentials in ~/.apigeerc:

    org: APIGEE_ORG
    username: APIGEE_USERNAME
    password: APIGEE_PASSWORD
    environment: ENVIRONMENT

## Commands

### Top level commands

    Commands:
      apigee apigeetool [COMMAND]  # Run a command using the apigeetool Node.js module
      apigee config [COMMAND]      # Run a command within the context of an app configuration
      apigee help [COMMAND]        # Describe available commands or one specific command
      apigee resource [COMMAND]    # Run a command within the context of a resource
      apigee settings              # Show the current apigeerc settings
      apigee version               # Shows the Apigee CLI version number

### To see sublevel commands, you can run:

    apigee help apigeetool
    apigee help config
    apigee help resource

### Usage

A. Deployment (leverages apigeetool Node.js module)

#### apigee apigeetool listdeployments [DEFAULT]

    # by environment
    $ apigee apigeetool listdeployments -e=ENVIRONMENT

    # by proxy name
    $ apigee apigeetool listdeployments -n PROXY_NAME

#### apigee apigeetool deploy

    $ apigee apigeetool deploy -e=ENVIRONMENT -n PROXY_NAME -d ROOT_DIR_OF_PROXY -V

#### apigee apigeetool nodedeploy

    $ apigee apigeetool nodedeploy -e=ENVIRONMENT -n NODE_PROXY_NAME -d ROOT_DIR_OF_NODE_PROXY -m MAIN_JS_FILE -b BASE_PATH -v secure

#### apigee apigeetool undeploy

    $ apigee apigeetool undeploy -e=ENVIRONMENT -n PROXY_NAME -D

#### apigee apigeetool fetchproxy

    $ apigee apigeetool fetchproxy -n PROXY_NAME -r REVISION_NUMBER

#### apigee apigeetool delete

NOTE: This deletes all revisions of PROXY_NAME. It is an error to delete a proxy that still has deployed revisions. Revisions must be undeployed using "undeploy" before this command may be used.

    $ apigee apigeetool delete -n PROXY_NAME

#### apigee apigeetool getlogs [from a Node app]

    $ apigee apigeetool getlogs -e=ENVIRONMENT -n NODE_PROXY_NAME


B. Configuration Settings on Apigee Server

#### apigee config list [DEFAULT]

    # defaults
    -e=test|--environment=test

    # List configs for default environment of test
    $ apigee config list

    # List config for a particular config_name
    $ apigee config list --config_name=configuration_one

#### apigee config push

    # defaults
    -e=test|--environment=test
    --config_name=configuration

    # Create config key-value map
    $ apigee config push --config_name=new_config

    # Update config key-value pair
    $ apigee config push key_one=value_one

    # Overwrite existing config key-value pair
    $ apigee config push key_one=changed_value_one --overwrite=true

#### apigee config delete

    # defaults
    -e=test|--environment=test
    --config_name=configuration

    # Delete config key-value pair (default config_name is configuration)
    $ apigee config delete --entry_name=key_one

    # Delete config for that config_name
    $ apigee config delete --config_name=configuration_one


C. Resource Files on Apigee Server

#### apigee resource list [DEFAULT]

    # List resource files for organization
    $ apigee resource list

    # Get resource file with resource_name
    $ apigee resource list --name=testing.js

#### apigee resource upload

    # Upload resource files from resource_folder
    $ apigee resource upload --folder=jsc

#### apigee resource delete

    # Delete resource file of resource_name
    $ apigee resource delete --name=testing.js

## Contributing

1. Fork it ( http://github.com/<my-github-username>/apigee_cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
