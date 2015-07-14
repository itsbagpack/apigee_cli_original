require 'spec_helper'
require 'apigee_cli/cli/app_config'

describe AppConfig do
  describe 'apigee config list' do
    it 'prints all the key value maps'
    it 'prints the key value pairs for --config_name'
  end

  describe 'apigee config push' do
    context 'when key value map with --config_name exists' do
      it 'creates a new key value map'
    end

    context 'when key value map with --config_name exists' do
      it 'allows you to push up a new key value pair'
      specify 'when a key value pair exists'
    end
  end

  describe 'apigee config delete' do
  end
end
