require 'apigee_cli/cli/thor_cli'

class Resource < ThorCli
  namespace 'resource'
  default_task :list

  RESOURCE_FILE_KEY = 'resourceFile'
  DEFAULT_RESOURCE_TYPE = 'jsc'

  # TODO: is there really a use case for .apigee_resources?
  DEFAULT_FOLDER = "#{ENV['HOME']}/.apigee_resources"

  desc 'list', 'List resource files'
  option :resource_name, type: :string
  def list
    resource_name = options[:resource_name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if resource_name
      response = resource.read(resource_name, DEFAULT_RESOURCE_TYPE)
      say response
    else
      pull_list(resource)
    end
  end

  desc 'upload', 'Upload resource files'
  option :resource_folder, type: :string, default: DEFAULT_FOLDER
  def upload
    resource_folder = options[:resource_folder]

    files = Dir.entries(resource_folder).select{ |f| f =~ /.js$/ }

    resource = ApigeeCli::ResourceFile.new(environment)

    files.each do |file|
      result = resource.upload file, DEFAULT_RESOURCE_TYPE, "jsc/#{file}"
      if result == :overwritten
        say "Deleting current resource for #{file}", :red
      elsif result == :new_file
        say "Creating resource for #{file}", :green
      end
    end
  end

  desc 'delete', 'Delete resource file'
  option :resource_name, type: :string
  def delete
    resource_name = options[:resource_name]

    resource = ApigeeCli::ResourceFile.new(environment)

    confirm = yes? "Are you sure you want to delete #{resource_name} from #{org}? [y/n]"

    if confirm && resource_name
      say "Deleting current resource for #{resource_name}", :red
      resource.remove(resource_name, DEFAULT_RESOURCE_TYPE)
    end
  end

  private

    def pull_list(resource)
      response = Hashie::Mash.new(resource.all)
      render_list(response[RESOURCE_FILE_KEY])
    end

    def render_list(resource_files)
      say "Resource files for #{org}", :blue
      resource_files.each do |resource_file|
        name = resource_file['name']
        type = resource_file['type']

        say "  #{type} file - #{name}", :green
      end
    end
end
