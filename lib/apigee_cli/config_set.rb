module ApigeeCli
  class ConfigSet < Base

    class << self
      def parse_filename(config_filename)
        filename_parts = config_filename.gsub(/.json$/,'').split('_')

        OpenStruct.new(
          {
            filename: config_filename,
            environment: filename_parts.last,
            name: filename_parts.slice(0, filename_parts.length - 1).join('_')
          }
        )
      end
    end

    def base_url
      "https://api.enterprise.apigee.com/v1/o/#{ENV['org']}/environments/#{environment}/keyvaluemaps"
    end

    def all
      response = get(base_url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def read(name)
      url = [base_url,name].join('/')
      response = get(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def write(name, data)
      body = {
        name: name,
        entry: data
      }
      response = post(base_url, body)
      if response.status != 201
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def remove(name)
      url = [base_url,name].join('/')
      response = delete(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end
  end
end
