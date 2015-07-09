class Resource < ThorCli
  namespace 'resource'
  default_task :list

  DEFAULT_RESOURCE_TYPE = 'jsc'

  desc 'list', 'List resource files'
  option :resource_type, type: :string, default: DEFAULT_RESOURCE_TYPE
  option :resource_name, type: :string
  def list
    resource_type = options[:resource_type]
    resource_name = options[:resource_name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if resource_name
      resource.read(resource_name, resource_type)
    else
      resource.all(resource_type)
    end
  end

  desc 'upload', 'Upload resource files'
  option :resource_type, type: :string, default: DEFAULT_RESOURCE_TYPE
  def upload
    resource_type = options[:resource_type]

    files = Dir.entries("jsc").select{ |f| f =~ /.js$/ }

    resource = ApigeeCli::ResourceFile.new(environment)

    files.each do |file|
      if resource.read(file, resource_type)
        puts "Deleting current resource for #{file}"
        resource.remove(file, resource_type)
      end

      puts "Creating resource for #{file}"
      resource.create(file, resource_type, "jsc/#{file}")
    end
  end

  desc 'delete', 'Delete resource file'
  option :resource_type, type: :string, default: DEFAULT_RESOURCE_TYPE
  option :resource_name, type: :string
  def delete
    resource_type = options[:resource_type]
    resource_name = options[:resource_name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if resource_name
      puts "Deleting current resource for #{resource_name}"
      resource.remove(resource_name, resource_type)
    end
  end
end
