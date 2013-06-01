require 'rubygems'
require 'capistrano-buildpack'

set :application, "bugsplatdotinfo"
set :repository, "git@git.bugsplat.info:peter/bugsplat.git"
set :scm, :git
set :additional_domains, ['bugsplat.info']

role :web, "empoknor.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"
set :use_ssl, true
set :force_ssl, true
set :ssl_cert_path, '/etc/nginx/certs/bugsplat.info.crt'
set :ssl_key_path, '/etc/nginx/certs/bugsplat.info.key'

read_env 'prod'

load 'deploy'

after "deploy" do
  run "cd #{current_path}; foreman run bundle exec rake email:send"
end
