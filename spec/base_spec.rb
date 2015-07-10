require 'spec_helper'
require 'apigee_cli/base'
require 'webmock'

include WebMock::API

describe ApigeeCli::Base do
  before do
    module ApigeeCli
      class Foo < Base
        def base_url
          "http://foos.com"
        end
      end
    end
  end

  let(:foo) { ApigeeCli::Foo.new }
  let(:username) { ApigeeCli.configuration.username }
  let(:password) { ApigeeCli.configuration.password }
  let(:file) { Rack::Test::UploadedFile.new('spec/fixtures/test.txt', 'text/plain') }

  describe '#get' do
    it 'performs a get via Faraday::Connection with basic auth' do
      expect_any_instance_of(Faraday::Connection).to receive(:basic_auth).with(username, password)
      expect_any_instance_of(Faraday::Connection).to receive :get

      foo.get(foo.base_url)
    end
  end

  describe '#upload_file' do
    it 'performs a post via Faraday::Connection with basic auth' do
      stub_request(:post, "http://example_user:password@foos.com/")
         .with(:body => "\"{\\\"leslie\\\":\\\"knope\\\"}\"",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Faraday v0.9.1'})
         .to_return(:status => 200, :body => "", :headers => {})
      expect_any_instance_of(Faraday::Connection).to receive(:basic_auth).with(username, password)
      expect_any_instance_of(Faraday::Connection).to receive :post

      foo.upload_file(foo.base_url, file)
    end

    it 'appends the right headers to the request' do
      stub_request(:post, "http://example_user:password@foos.com/")
         .with(:body => "This is a test.\n",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Length'=>'16', 'Content-Type'=>'application/octet-stream', 'User-Agent'=>'Faraday v0.9.1'})
         .to_return(:status => 200, :body => "", :headers => {})

      result = foo.upload_file(foo.base_url, file)
      request_headers = result.env.request_headers

      expect(request_headers['Content-Type']).to eq 'application/octet-stream'
      expect(request_headers['Content-Length']).to eq File.size(file).to_s
      # TODO: check request body? it is currently an empty string...
    end
  end

  describe '#post' do
    it 'performs a post via Faraday::Connection with basic auth' do
      expect_any_instance_of(Faraday::Connection).to receive(:basic_auth).with(username, password)
      expect_any_instance_of(Faraday::Connection).to receive :post

      foo.post(foo.base_url, { leslie: 'knope' }.to_json)
    end

    it 'appends the right headers to the request' do
      result = foo.post(foo.base_url, { leslie: 'knope' }.to_json)
      request_headers = result.env.request_headers

      expect(request_headers['Content-Type']).to eq 'application/json'
    end
  end

  describe '#delete' do
    it 'performs a delete via Faraday::Connection with basic auth' do
      expect_any_instance_of(Faraday::Connection).to receive(:basic_auth).with(username, password)
      expect_any_instance_of(Faraday::Connection).to receive :delete

      foo.delete(foo.base_url)
    end

    # TODO: should delete be doing more?
  end
end
