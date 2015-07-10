class Resource < ThorCli
  namespace 'resource'
  default_task :list

  RESOURCE_FILE_KEY = 'resourceFile'
  DEFAULT_RESOURCE_TYPE = 'jsc'
  DEFAULT_FOLDER = "#{ENV['HOME']}/.apigee_resources"

  desc 'list', 'List resource files'
  option :resource_type, type: :string, default: DEFAULT_RESOURCE_TYPE
  option :resource_name, type: :string
  def list
    resource_type = options[:resource_type]
    resource_name = options[:resource_name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if resource_name
      response = resource.read(resource_name, resource_type)

      file_name = ask "What would you like to name this file?"

      File.open(file_name, 'w') do |file|
        file.write(response)
      end
    else
      pull_list(resource, resource_type)
    end
  end

  desc 'upload', 'Upload resource files'
  option :resource_type, type: :string, default: DEFAULT_RESOURCE_TYPE
  option :resource_folder, type: :string, default: DEFAULT_FOLDER
  def upload
    resource_type = options[:resource_type]
    resource_folder = options[:resource_folder]

    files = Dir.entries("#{resource_folder}").select{ |f| f =~ /.js$/ }

    resource = ApigeeCli::ResourceFile.new(environment)

    files.each do |file|
      if resource.read(file, resource_type)
        say "Deleting current resource for #{file}", :red
        resource.remove(file, resource_type)
      end

      say "Creating resource for #{file}", :green
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

    confirm = yes? "Are you sure you want to delete #{resource_name} from #{org}? [y/n]"

    if confirm && resource_name
      say "Deleting current resource for #{resource_name}", :red
      resource.remove(resource_name, resource_type)
    end
  end

  private

    def pull_list(resource, resource_type)
      response = Hashie::Mash.new(resource.all(resource_type))
      render_list(response[RESOURCE_FILE_KEY])
    end

    def render_list(resource_files)
      say "Resource files for #{org}", :blue
      resource_files.each do |resource_file|
        name = resource_file['name']
        type = resource_file['type']

        say "\s\s#{type} file - #{name}", :green
      end
    end
end
