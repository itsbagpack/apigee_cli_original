require 'spec_helper'

RSpec.describe Resource do
  describe 'apigee resource list' do
    it 'prints the names of the files, by default'
    it 'prints the content of the file for the requested --name'
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
