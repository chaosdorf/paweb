require 'bundler/capistrano'

set :application, 'paweb'
set :repository,  'https://github.com/mxey/paweb.git'
set :user, 'http'
set :deploy_to, '/srv/http/paweb' 
set :use_sudo, false
set :default_environment, {
  'GEM_HOME' => '/srv/http/.gem'
}

role :app, 'webserver.chaosdorf.dn42'
role :web, 'webserver.chaosdorf.dn42'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# from http://matt.west.co.tt/ruby/capistrano-without-a-database/
namespace :deploy do
	desc "Override deploy:cold to NOT run migrations - there's no database"
	task :cold do
		update
		start
	end
end