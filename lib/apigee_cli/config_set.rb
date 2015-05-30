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
      "https://api.enterprise.apigee.com/v1/o/#{org}/environments/#{environment}/keyvaluemaps"
    end

    def list_configs
      # We need the expand: true option to get an expanded view of the KeyValueMaps
      response = get(base_url, expand: true)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def read_config(config_name)
      url = [base_url, config_name].join('/')
      response = get(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def write_config(config_name, data)
      body = {
        name: config_name,
        entry: data
      }
      response = post(base_url, body)
      if response.status != 201
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def update_config(config_name, data)
      url = [base_url, config_name].join('/')
      body = {
        name: config_name,
        entry: data
      }
      response = put(url, body)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def remove_config(config_name)
      url = [base_url, config_name].join('/')
      response = delete(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def remove_entry(config_name, entry_name)
      url = [base_url, config_name, 'entries', entry_name].join('/')

      response = delete(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end
  end
end
