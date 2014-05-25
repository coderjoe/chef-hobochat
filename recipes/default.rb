# Encoding: utf-8
# Cookbook Name:: hobochat
# Recipe:: default
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set[:ircd][:services][:password] = secure_password
node.set[:ircd][:server][:admin][:password] = secure_password

include_recipe 'apt'
include_recipe 'ircd-ratbox'
include_recipe 'kiwiirc'

template "#{node[:ircd][:server][:directory]}/etc/ircd.conf" do
  source 'ratbox.conf.erb'
  owner node[:ircd][:server][:user]
  group node[:ircd][:server][:group]
  mode 0644
  variables(
    admin_password: node[:ircd][:server][:admin][:password],
    services_password: node[:ircd][:services][:password]
  )
end

template "#{node[:ircd][:services][:directory]}/etc/ratbox-services.conf" do
  source 'ratbox-services.conf.erb'
  owner node[:ircd][:services][:user]
  owner node[:ircd][:services][:group]
  mode 0644
  variables(
    services_password: node[:ircd][:services][:password]
  )
end

services_dir = node[:ircd][:services][:directory]

command = './generate-schema.pl'
bash command do
  code command
  cwd "#{services_dir}/src/tools"
  user node[:ircd][:services][:user]
  group node[:ircd][:services][:group]
end

database_path = "#{services_dir}/etc/ratbox-services.db"
schema_path = "#{services_dir}/src/tools/schema-sqlite.txt"
command = "./sqlite3 #{database_path} < #{schema_path}"
bash command do
  code command
  cwd "#{services_dir}/bin"
  user node[:ircd][:services][:user]
  group node[:ircd][:services][:group]
end
