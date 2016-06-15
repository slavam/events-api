# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'events'
set :repo_url, 'git@github.com:slavam/events-api.git'
# set :repo_url, 'git@github.com:Moleculus/Events-API.git'
set :user,            'events'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/events'

# Default value for :scm is :git
set :scm, :git

# set :deploy_via, "remote_cache"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# set :ssh_options, { forward_agent: true, paranoid: true, keys: "~/.ssh/id_rsa" }
# set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
# set :ssh_options, { user: 'events', forward_agent: true, auth_methods: %w(publickey password) }
set :ssh_options, {forward_agent: true, auth_methods: %w(publickey)}

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
# set :default_env, { path: "~/.rbenv/shims:~/.rbenv/bin:$PATH" }
# SSHKit.config.command_map[:rake] = "#{fetch(:default_env)[:rvm_bin_path]}/rvm ruby-#{fetch(:rvm_ruby_version)} do bundle exec rake"
# set :rvm_type, :system
set :rvm_ruby_version, '2.3.0@rails5.0'

# Default value for keep_releases is 5
# set :keep_releases, 5

set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
# set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to true if using ActiveRecord

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless 'git rev-parse HEAD' == 'git rev-parse my_ev_gh/master'
      # unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run 'git push' to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  # after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma

=begin
namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      # unless `git rev-parse HEAD` == `git rev-parse origin/master`
      unless `git rev-parse HEAD` == `git rev-parse my_ev_gh/master`
      # unless `git rev-parse HEAD` == `git rev-parse ev_on_gh/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  
  before :starting,     :check_revision
  
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :log do
  namespace :tail do
    desc "Show the production log"
    task :app do
      on roles(:app) do
        run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
          puts "#{data}"
          break if stream == :err
        end
      end
    end
  end
end

namespace :db do
  desc "Create database yaml in shared path"
  task :configure do
    set :database do
      Capistrano::CLI.password_prompt "Database: "
    end

    set :database_username do
      Capistrano::CLI.password_prompt "Database Username: "
    end

    set :database_password do
      Capistrano::CLI.password_prompt "Database Password: "
    end

    set :database_host do
      Capistrano::CLI.password_prompt "Database Host: "
    end

    db_config = <<-EOF
      production:
        adapter: postgresql
        encoding: unicode
        pool: 5
        database: events
        username: events
        password: mLSECDQwbe
        host: www.events.2cubes.ru
    EOF

    on roles(:db) do
      # run "mkdir -p  /home/events/shared/config/"
      put db_config, " /home/events/shared/config/database.yml"
    end
  end

  # desc "Make symlink for database yaml"
  # task :symlink do
  #   run "ln -nfs /home/events/shared/config/database.yml #{latest_release}/config/database.yml"
  # end
end

# before 'deploy:setup', 'db:configure'
before 'deploy', 'db:configure'
=end