require 'spec_helper'
require 'apigee_cli/cli/app_config'

describe AppConfig do
  describe 'apigee config list' do
    it 'prints all the key value maps' do
      app_config = AppConfig.new([])
      app_config.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ConfigSet).to receive(:list_configs).and_return({
        "keyValueMap" => [
          { "entry" => [ { "name" => "key_one", "value" => "value_one" },
                         { "name" => "key_two", "value" => "value_two" }
                       ],
            "name" => "configuration"
          }
        ]
      })

      app_config.invoke(:list)

      expect(app_config.shell.printed).to eq [
        "Environment: test, Config Name: configuration",
        "  key_one: value_one",
        "  key_two: value_two"
      ]
    end

    it 'prints the key value pairs for --config_name' do
      app_config = AppConfig.new([], config_name: 'teehee')
      app_config.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ConfigSet).to receive(:read_config).with('teehee').and_return({
        "entry" => [ { "name" => "key_a", "value" => "value_a" },
                     { "name" => "key_b", "value" => "value_b" }
                   ],
        "name" => "teehee"
      })

      app_config.invoke(:list)

      expect(app_config.shell.printed).to eq [
        "Environment: test, Config Name: teehee",
        "  key_a: value_a",
        "  key_b: value_b"
      ]
    end

    specify 'when config does not exist on Apigee Server, an error is rendered' do
      app_config = AppConfig.new([])
      app_config.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ConfigSet).to receive(:list_configs).and_raise("Map does not exist")

      app_config.invoke(:list)

      expect(app_config.shell.printed).to eq ["Map does not exist"]
    end
  end

  describe 'apigee config push' do
    context 'when key value map with --config_name doesn\'t exist' do
      before do
        allow_any_instance_of(ApigeeCli::ConfigSet).to receive(:read_config).and_raise(RuntimeError, "keyvaluemap_doesnt_exist")
      end

      it 'creates a new key value map' do
        app_config = AppConfig.new([], config_name: 'teehee')
        app_config.shell = ShellRecorder.new

      end
    end

    context 'when key value map with --config_name exists' do
      context 'when a key value pair exists' do
        it 'gets replaced with new key value pair if --overwrite=true'
      end

      context 'when a key value pair doesn\'t exist' do
        it 'gets added to the key value map'
      end
    end
  end

  describe 'apigee config delete' do
  end
end
