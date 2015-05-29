require 'faraday'

module ApigeeCli
  class Base
    attr_accessor :org, :environment

    def initialize(environment = nil)
      @username     = ApigeeCli.configuration.username
      @password     = ApigeeCli.configuration.password
      @org          = ApigeeCli.configuration.org
      @environment  = environment || ApigeeCli.configuration.environment
    end

    def get(url)
      conn = Faraday.new(url: url)
      conn.basic_auth(@username, @password)
      conn.get
    end

    def upload_file(url, file)
      conn = Faraday.new(url: url)
      conn.basic_auth(@username, @password)
      conn.post do |request|
        request.headers['Content-Type'] = "application/octet-stream"
        request.headers['Content-Length'] = File.size(file).to_s
        request.body = Faraday::UploadIO.new(file, 'text/plain')
      end
    end

    def post(url, body)
      conn = Faraday.new(url: url)
      conn.basic_auth(@username, @password)
      conn.post do |request|
        request.headers['Content-Type'] = "application/json"
        request.body = body.to_json
      end
    end

    def delete(url)
      conn = Faraday.new(url: url)
      conn.basic_auth(@username, @password)
      conn.delete
    end

    def response_error(response)
      raise "Response Error: #{response.status} #{response.body}"
    end

  end
end
