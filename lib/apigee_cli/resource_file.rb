module ApigeeCli
  class ResourceFile < Base
    def base_url
      "https://api.enterprise.apigee.com/v1/organizations/#{org}/resourcefiles"
    end

    def all(resource_type = nil)
      url = [base_url,resource_type].join('/')
      response = get(url)
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

  end
end
