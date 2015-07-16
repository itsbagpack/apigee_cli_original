require 'spec_helper'
require 'apigee_cli/cli/resource'

describe Resource do
  describe 'apigee resource list' do
    it 'prints the names of the files, by default' do
      resource = Resource.new([])
      resource.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:all).and_return({
        "resourceFile" => [
          { "name" => "lodash.js", "type" => "jsc" },
          { "name" => "honeybadger.js", "type" => "jsc" }
        ]
      })

      resource.invoke(:list)

      expect(resource.shell.printed).to eq [
        "Resource files for bellycard",
        "  jsc file - lodash.js",
        "  jsc file - honeybadger.js"
      ]
    end

    it 'prints the content of the file for the requested --name' do
      resource = Resource.new([], name: 'test.js')
      resource.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:read)
        .with('test.js', 'jsc')
        .and_return("Hello World")

      resource.invoke(:list)

      expect(resource.shell.printed).to eq ["Hello World"]
    end
  end

  describe 'apigee resource upload' do
    it 'requires the --folder from which to upload files' do
      resource = Resource.new([])

      expect {
        resource.invoke(:upload)
      }.to raise_error Thor::RequiredArgumentMissingError
    end

    it 'uploads only .js files in --folder to the Apigee server' do
      resource = Resource.new([], folder: File.expand_path('../fixtures', __dir__))
      resource.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:upload).and_return(:new_file)

      resource.invoke(:upload)

      expect(resource.shell.printed).to_not include 'Creating resource for test.txt'
      expect(resource.shell.printed).to eq [
        "Creating resource for test.js",
        "Creating resource for test2.js"
      ]
    end

    specify 'when the file exists, it deletes it before uploading' do
      resource = Resource.new([], folder: File.expand_path('../fixtures', __dir__))
      resource.shell = ShellRecorder.new
      allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:upload).and_return(:overwritten)

      resource.invoke(:upload)

      expect(resource.shell.printed).to eq [
        "Deleting current resource for test.js",
        "Deleting current resource for test2.js"
      ]
    end
  end

  describe 'apigee resource delete' do
    it 'requires the --name of the file to delete' do
      resource = Resource.new([])

      expect {
        resource.invoke(:delete)
      }.to raise_error Thor::RequiredArgumentMissingError
    end

    context 'when user gives permission to delete the file' do
      before do
        allow_any_instance_of(ShellRecorder).to receive(:yes?).and_return true
      end

      it 'deletes the file if it exists' do
        resource = Resource.new([], name: 'test3.js')
        resource.shell = ShellRecorder.new
        allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:remove)
          .with('test3.js', 'jsc')
          .and_return("Deleted")

        resource.invoke(:delete)

        expect(resource.shell.printed).to eq [
          "Deleting current resource for test3.js"
        ]
      end

      it 'renders an error when the file doesn\'t exist on the server' do
        resource = Resource.new([], name: 'test3.js')
        resource.shell = ShellRecorder.new
        allow_any_instance_of(ApigeeCli::ResourceFile).to receive(:remove).and_raise("Resource already exists")

        expect {
          resource.invoke(:delete)
        }.to raise_error SystemExit

        expect(resource.shell.printed).to include "Resource already exists"
      end
    end

    context 'when user doesn\'t give permission to delete the file' do
      before do
        allow_any_instance_of(ShellRecorder).to receive(:yes?).and_return false
      end

      it 'doesn\'t delete the file' do
        resource = Resource.new([], name: 'test3.js')
        resource.shell = ShellRecorder.new

        expect_any_instance_of(ApigeeCli::ResourceFile).to_not receive(:remove)

        expect {
          resource.invoke(:delete)
        }.to raise_error SystemExit
      end
    end
  end
end
