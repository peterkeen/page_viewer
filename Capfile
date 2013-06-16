require 'rubygems'
require 'capistrano-buildpack'

set :repository, "git@git.bugsplat.info:peter/page_viewer.git"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"
set :scm, :git
role :web, "subspace.bugsplat.info"

task :guide do
  set :application, "guide"
  set :base_port, 6700
  read_env 'guide'
end

task :notes do
  set :application, "notes"
  set :base_port, 6800
  read_env 'notes'
end

set :user, "peter"

set :concurrency, "web=1"

load 'deploy'
