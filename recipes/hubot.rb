# Encoding: utf-8
# Cookbook Name:: hobochat
# Recipe:: default
include_recipe 'nodejs'
include_recipe 'nodejs::npm'

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

hubot_user = node[:hubot][:name]
hubot_repo = node[:hubot][:repository]
hubot_irc_rooms = node[:hubot][:irc][:rooms]
hubot_dir = "/home/#{hubot_user}"

package 'redis-server'

group hubot_user do
  system true
end

user hubot_user do
  gid hubot_user
  home hubot_dir
  shell '/bin/false'
  system true
end

directory hubot_dir do
  owner hubot_user
  group hubot_user
  recursive true
  mode 0750
end

git hubot_dir do
  repository hubot_repo
  revision 'master'
  user hubot_user
  group hubot_user
end

template "#{hubot_dir}/.hubotrc" do
  source 'hubotrc.erb'
  owner hubot_user
  group hubot_user
  mode 0750
  variables(
    env: {
      HUBOT_IRC_SERVER: 'localhost',
      HUBOT_IRC_NICK: hubot_user,
      HUBOT_IRC_ROOMS: hubot_irc_rooms,
      HUBOT_IRC_UNFLOOD: 'true'
    }
  )
end

template "#{hubot_dir}/hubot.sh" do
  source 'hubot.init.erb'
  owner hubot_user
  group hubot_user
  mode 0750
  variables(
    name: hubot_user,
    directory: hubot_dir
  )
end
