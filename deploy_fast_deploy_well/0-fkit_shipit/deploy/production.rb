server 'havk64.tech', user: 'deploy', roles: %w{app web}
set :branch, "master"

set :ssh_options, {
    :forward_agent => true
}
