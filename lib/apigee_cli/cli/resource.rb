require 'apigee_cli/cli/thor_cli'

class Resource < ThorCli
  namespace 'resource'
  default_task :list

  RESOURCE_FILE_KEY = 'resourceFile'
  DEFAULT_RESOURCE_TYPE = 'jsc'

  desc 'list', 'List resource files'
  option :name, type: :string
  def list
    name = options[:name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if name
      response = resource.read(name, DEFAULT_RESOURCE_TYPE)
      say response
    else
      pull_list(resource)
    end
  end

  desc 'upload', 'Upload resource files'
  option :folder, type: :string, required: true
  def upload
    folder = options[:folder]

    files = Dir.entries(folder).select{ |f| f =~ /.js$/ }

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
  option :name, type: :string, required: true
  def delete
    name = options[:name]

    resource = ApigeeCli::ResourceFile.new(environment)

    confirm = yes? "Are you sure you want to delete #{name} from #{org}? [y/n]"

    if confirm
      begin
        say "Deleting current resource for #{name}", :red
        resource.remove(name, DEFAULT_RESOURCE_TYPE)
      rescue RuntimeError => e
        render_error(e)
        exit
      end
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

    def render_error(error)
      say error.to_s, :red
    end
end
