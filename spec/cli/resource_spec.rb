require 'spec_helper'
require 'apigee_cli/cli/resource'

#   desc "four", "invoke four"
#   option :defaulted_value, :type => :string, :default => 'default'
#   def four
#     options.defaulted_value
#   end
#
#     it "allows customized options to be given" do
#       base = A.new([], :last_name => "Wrong")
#       expect(base.invoke(B, :one, %w[Jose], :last_name => "Valim")).to eq("Valim, Jose")
#     end
#
#     it "reparses options in the new class" do
#       expect(A.start(%w[invoker --last-name Valim])).to eq("Valim, Jose")
#     end
#
# class B < Thor
#   class_option :last_name, :type => :string
#
#   desc "one FIRST_NAME", "invoke one"
#   def one(first_name)
#     "#{options.last_name}, #{first_name}"
#   end
#
#   desc "two", "invoke two"
#   def two
#     options
#   end

RSpec.describe Resource do
  def recorder
    Class.new {
      def say(message, color=nil)
        printed << message
      end

      def printed
        @printed ||= []
      end
    }.new
  end

  describe 'apigee resource list' do
    it 'prints the names of the files, by default' do
      resource = Resource.new([])
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:all).and_return({
        "resourceFile" => [
          { "name" => "lodash.js", "type" => "jsc" },
          { "name" => "honeybadger.js", "type" => "jsc" }
        ]
      })

      resource.shell = recorder

      resource.invoke(:list)

      expect(resource.shell.printed).to eq [
        "Resource files for bellycard",
        "  jsc file - lodash.js",
        "  jsc file - honeybadger.js"
      ]
    end

    it 'prints the content of the file for the requested --name' do
      resource = Resource.new([], resource_name: 'test.js')
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:read)
        .with('test.js', 'jsc')
        .and_return("Hello World")

      resource.shell = recorder

      resource.invoke(:list)

      expect(resource.shell.printed).to eq ['Hello World']
    end
  end

  describe 'apigee resource upload' do
    it 'uploads the files in --folder to the Apigee server'
    it 'ignores files without a .js extension'
    specify 'when the folder exists, it deletes it before uploading'
  end

  describe 'apigee resource delete' do
    it 'requires the --name of the file to delete'

    context 'when user gives permission to delete the file' do
      it 'deletes the file if it exists'
      it 'does ?? when the file doesn\'t exist on the server'
    end

    context 'when user doesn\'t give permission to delete the file' do
      it 'doesn\'t delete the file'
    end
  end
end
