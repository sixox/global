# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

server '82.115.26.171', user: 'deploy', roles: %w{app db web}


# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
# Load webpacker tasks
namespace :deploy do
  desc 'Install Yarn dependencies'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute :yarn, 'install --production --silent'
      end
    end
  end

  desc 'Compile assets with webpacker'
  task :compile_assets do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rails assets:precompile'
        end
      end
    end
  end
end

# Run the necessary tasks during deployment
after 'deploy:updated', 'deploy:yarn_install'
after 'deploy:yarn_install', 'deploy:compile_assets'
namespace :deploy do
  desc 'Copy package.json and yarn.lock'
  task :copy_files do
    on roles(:web) do
      within release_path do
        execute :cp, "#{shared_path}/config/package.json", "./"
        execute :cp, "#{shared_path}/config/yarn.lock", "./"
      end
    end
  end

  desc 'Install Yarn dependencies'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute :yarn, 'install --production --silent'
      end
    end
  end

  desc 'Compile assets with webpacker'
  task :compile_assets do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rails assets:precompile'
        end
      end
    end
  end
end

# Run the necessary tasks during deployment
after 'deploy:updated', 'deploy:copy_files'
after 'deploy:copy_files', 'deploy:yarn_install'
after 'deploy:yarn_install', 'deploy:compile_assets'


