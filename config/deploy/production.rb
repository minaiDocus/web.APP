set :deploy_to, '/home/deploy/main/'

set :repo_url, 'git@github.com:i-docus/main.git'

set :branch, 'master'

set :rvm_ruby_version, '2.6.5'

server 'staging-v3.idocus.com', user: 'deploy', roles: %w{app db web worker}

