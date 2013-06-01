require 'rubygems'
require 'capistrano-buildpack'

set :application, "guide"
set :repository, "git@git.bugsplat.info:peter/page_viewer.git"
set :scm, :git

role :web, "subspace.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"

read_env 'prod'

load 'deploy'
