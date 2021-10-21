set :deploy_to, '/home/deploy/my'

set :linked_dirs, fetch(:linked_dirs, []).push('files')

set :repo_url, 'git@github.com:i-docus/web.APP.git'

set :branch, 'staging'

set :rvm_ruby_version, '2.6.5'

server 'staging-v3.idocus.com', user: 'deploy', roles: %w{app db web worker}
