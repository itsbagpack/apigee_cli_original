ENV['RACK_ENV'] = 'test'

require 'apigee_cli'
require 'rack/test'
require 'webmock'

include WebMock::API

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:username).and_return('example_user')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:password).and_return('password')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:environment).and_return('test')
    allow_any_instance_of(ApigeeCli::Configuration).to receive(:org).and_return('example_org')
  end
end

class ShellRecorder
  def say(message, color=nil)
    printed << message
  end

  def printed
    @printed ||= []
  end
end
