# Encoding: utf-8

package 'monit'

ratbox_user = node[:ircd][:server][:user]
ratbox_group = node[:ircd][:server][:group]
ratbox_path = node[:ircd][:server][:directory]

services_user = node[:ircd][:services][:user]
services_group = node[:ircd][:services][:group]
services_path = node[:ircd][:services][:directory]

service 'monit' do
  action :stop
end

template '/etc/monit/conf.d/ratbox.monit.conf' do
  source 'monit.service.conf.erb'
  owner 'root'
  group 'root'
  mode 0750
  variables(
    name: 'ratbox-ircd',
    user: ratbox_user,
    group: ratbox_group,
    pid_file: "#{ratbox_path}/etc/ircd.pid",
    start: "#{ratbox_path}/bin/ircd",
    stop: "/bin/kill -9 `cat #{ratbox_path}/etc/ircd.pid`",
    watch_files: [
      { name: 'ircd.conf', path: "#{ratbox_path}/etc/ircd.conf" }
    ]
  )
end

services_pid = "#{services_path}/var/run/ratbox-services.pid"
services_start = "#{services_path}/sbin/ratbox-services"
services_stop = "/bin/kill -9 `cat #{services_pid}`"

template '/etc/monit/conf.d/ratbox-services.monit.conf' do
  source 'monit.service.conf.erb'
  owner 'root'
  group 'root'
  mode 0750
  variables(
    name: 'ratbox-services',
    user: services_user,
    group: services_group,
    pid_file: services_pid,
    start: services_start,
    stop: services_stop,
    watch_files: [
      {
        name: 'ratbox-services.conf',
        path: "#{services_path}/etc/ratbox-services.conf"
      }
    ]
  )
end

kiwi_user = node[:kiwiirc][:user]
kiwi_group = node[:kiwiirc][:group]
kiwi_path = node[:kiwiirc][:directory]
kiwi_config = "#{kiwi_path}/config.js"
kiwi_pid = "#{kiwi_path}/kiwiirc.pid"
kiwi_wrapper = "#{kiwi_path}/monit-wrapper.sh"
kiwi_build = "#{kiwi_wrapper} build"
kiwi_start = "#{kiwi_wrapper} start -c #{kiwi_config} -p #{kiwi_pid}"
kiwi_stop = "#{kiwi_wrapper} stop"

template "#{kiwi_path}/monit-wrapper.sh" do
  source 'monit-wrapper.sh.erb'
  owner kiwi_user
  group kiwi_group
  mode 0750
  variables(
    home: kiwi_path,
    command: "#{kiwi_path}/kiwi"
  )
end

template '/etc/monit/conf.d/kiwiirc.monit.conf' do
  source 'monit.service.conf.erb'
  owner 'root'
  group 'root'
  mode 0750
  variables(
    name: 'kiwiirc',
    user: kiwi_user,
    group: kiwi_group,
    pid_file: kiwi_pid,
    start: "/bin/bash -c '#{kiwi_build} && #{kiwi_start}'",
    stop: "#{kiwi_stop}",
    watch_files: [
      { name: 'config.js', path: kiwi_config }
    ]
  )
end

hubot_name = node[:hubot][:name]
hubot_path = "/home/#{hubot_name}"
hubot_pid = "#{hubot_path}/#{hubot_name}.pid"
hubot_start = "#{hubot_path}/monit-wrapper.sh start"
hubot_stop = "#{hubot_path}/monit-wrapper.sh stop"

template "#{hubot_path}/monit-wrapper.sh" do
  source 'monit-wrapper.sh.erb'
  owner hubot_name
  group hubot_name
  mode 0750
  variables(
    home: hubot_path,
    command: "#{hubot_path}/hubot.sh"
  )
end

template "/etc/monit/conf.d/#{hubot_name}.monit.conf" do
  source 'monit.service.conf.erb'
  owner 'root'
  group 'root'
  mode 0750
  variables(
    name: hubot_name,
    user: hubot_name,
    group: hubot_name,
    pid_file: hubot_pid,
    start: hubot_start,
    stop: hubot_stop,
    watch_files: [
      { name: '.hubotrc', path: "#{hubot_path}/.hubotrc" }
    ]
  )
end

service 'monit' do
  action [:enable, :start]
end
