require 'apigee_cli'
require 'rack/test'

RSpec.configure do |config|
  config.before(:each) do
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:username).and_return('example_user')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:password).and_return('password')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:environment).and_return('test')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:org).and_return('example_org')
  end
end
