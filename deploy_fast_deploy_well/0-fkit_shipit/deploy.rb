lock '3.5.0'

set :application, 'Le_chemin_francophone'
set :repo_url, 'git@github.com:havk64/CFSF.git'
set :deploy_to, '/home/deploy/CFSF'
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_via, :remote_cache
set :linked_files, ["config/secrets.json"]

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
