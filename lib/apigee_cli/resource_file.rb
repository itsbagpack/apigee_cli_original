module ApigeeCli
  class ResourceFile < Base

    RESOURCE_FILE_KEY = 'resourceFile'
    DEFAULT_RESOURCE_TYPE = 'jsc'

    def base_url
      "https://api.enterprise.apigee.com/v1/organizations/#{org}/resourcefiles"
    end

    def all
      response = get(base_url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def read(name, resource_type)
      url = [base_url,resource_type,name].join('/')
      response = get(url)
      if response.status == 404
        nil
      elsif response.status != 200
        response_error(response)
      else
        response.body
      end
    end

    def create(name, resource_type, file)
      url = "#{base_url}?name=#{name}&type=#{resource_type}"
      response = upload_file(url, file)
      if response.status != 201
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def remove(name, resource_type)
      url = [base_url,resource_type,name].join('/')
      response = delete(url)
      if response.status != 200
        response_error(response)
      else
        JSON.parse(response.body)
      end
    end

    def upload(name, resource_type, file)
      if read(name, resource_type)
        result = :overwritten
        remove(name, resource_type)
      else
        result = :new_file
      end
      create(name, resource_type, file)
      result
    end

  end
end
