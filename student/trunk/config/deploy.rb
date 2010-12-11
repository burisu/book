require 'mongrel_cluster/recipes'

set :application, "rotex"
set :repository,  "https://svn.rotex1690.org/rotex"

set :runner, "brice"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/www.rotex1690.org/"

set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion

role :app, "www.rotex1690.org"
role :web, "www.rotex1690.org"
role :db,  "www.rotex1690.org", :primary => true
