class ApigeeTool < ThorCli
  namespace 'apigeetool'
  default_task :listdeployments

  no_commands do
    def load_config
      @username = ApigeeCli.configuration.username
      @password = ApigeeCli.configuration.password
      @org      = ApigeeCli.configuration.org
      @env      = environment
    end
  end

  desc 'deploy', 'Deploy a proxy'
  def deploy(*args)
    load_config
    say `apigeetool deployproxy -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'nodedeploy', 'Deploy a node app'
  def nodedeploy(*args)
    load_config
    say `apigeetool deploynodeapp -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'undeploy', 'Undeploy a proxy or node app'
  def undeploy(*args)
    load_config
    say `apigeetool undeploy -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'listdeployments', 'List all the deployments for a given environment'
  def listdeployments(*args)
    load_config
    say `apigeetool listdeployments -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'fetchproxy', 'Download a proxy as a zip file'
  def fetchproxy(*args)
    load_config
    say `apigeetool fetchproxy -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'delete', 'Delete a proxy or node app'
  def deleteproxy(*args)
    load_config
    say `apigeetool delete -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end

  desc 'getlogs', 'Retrieve the last set of logs from a Node app'
  def getlogs(*args)
    load_config
    say `apigeetool getlogs -u #{@username} -p #{@password} -o #{@org} -e #{@env} #{args.join(' ')}`
  end
end
