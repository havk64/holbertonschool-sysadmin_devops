#
# Cookbook Name:: holberton-wrapper
# Recipe:: default
#
# Copyright (C) 2016 Alexandro de Oliveira
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'openssh'
include_recipe 'ntp'
include_recipe 'user'

directory '/var/run/sshd' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

begin
  r = resources(service: 'ssh')
  if 'debian' == node['platform']
    r.provider = Chef::Provider::Service::Debian
  end
end

user_account 'holberton' do
  comment 'Holberton User'
  ssh_keys 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRgomCmh+LcBwZOgmQZw3SvLFDBD0LGZN6ZoZnP70JvXMeEFiF9CtazJZObh6+PSwVkwrH5t3jznJcpm+vLDlmfy51WyPMj+vtTSVRfAacdv3N4D0/NiDUwwESvIQQgwQparyA/xkcbApRqa9ym7Le+0GQqRXFz/nt/HFijzbBDwfVNsc2aurfwLClJdzDrm6BZO4QAtE7OaMM/1yMOri6MahsOgl71OZ5dgUmVCUvJUZvGTVMnhgyFsYQ/aI5T0qQgQZoA0ao+nwqbKEjlAUJ/G5TqoczOXqWznYtfiHcdFCcBKdU9JLMZFNaFueHlCwrw4uEpw9v3ISKXhCJenDqNQYCIDDa/3nkvSKiqAGm189vDQOr8jt3rSCFZ7ceIW3ot+BV6UBFoKaF4z7Ve3W1QH8cnvUlL10G4HewHxVmeT762sWoRZcVQNygslCveii6BP8mPoayt8Gg1SDoFZBc90EwmOl/xvd/QB3FBd9ZkwA1ddATBiCk4LF6V2mo/f8l5Tb6gdR/2Vl0BUJhHyha26zdKpFpJr5ygqtuimH2OIZ4+W78RKH/0+/7OkKPl4KBbpyfD8yf+VU/fsKDXfjC5E+5V4+4Iu1DWLUiTc4xv+6/dxSTG3i4VcJ6DrgEk+TYRnCgKn7XKI/6maPPvtv/+olCzX4zQ/ehGIqO8N1IDw=='
end

apt_repository 'dotdeb' do
  uri 'http://packages.dotdeb.org'
  components ['main']
end

package 'nginx'

service 'nginx' do
  action [:enable, :start]
  provider Chef::Provider::Service::Debian
end

package 'net-tools'
