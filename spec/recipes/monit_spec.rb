# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::monit' do
  let(:ratbox_path) { '/home/ratfake' }
  let(:ratbox_user) { 'sommadaga' }
  let(:ratbox_group) { 'frekada' }

  let(:services_path) { '/home/servingstuff' }
  let(:services_user) { 'servington' }
  let(:services_group) { 'servergroup' }

  let(:kiwi_path) { '/home/kiwifruit' }
  let(:kiwi_user) { 'kiwiman' }
  let(:kiwi_group) { 'kiwiparty' }

  let(:hubot_name) { 'mrroboto' }

  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new do |node|
      node.set[:ircd][:server][:directory] = ratbox_path
      node.set[:ircd][:server][:user] = ratbox_user
      node.set[:ircd][:server][:group] = ratbox_group

      node.set[:ircd][:services][:directory] = services_path
      node.set[:ircd][:services][:user] = services_user
      node.set[:ircd][:services][:group] = services_group

      node.set[:kiwiirc][:directory] = kiwi_path
      node.set[:kiwiirc][:user] = kiwi_user
      node.set[:kiwiirc][:group] = kiwi_group

      node.set[:hubot][:name] = hubot_name
    end.converge(described_recipe)
  end

  it 'should install the monit package' do
    expect(chef_run).to install_package('monit')
  end

  it 'should configure monit to launch ratbox ircd' do
    expect(chef_run).to create_template(
      '/etc/monit/conf.d/ratbox.monit.conf'
    ).with(
      source: 'monit.service.conf.erb',
      owner: 'root',
      group: 'root',
      mode: 0750,
      variables: {
        name: 'ratbox-ircd',
        user: ratbox_user,
        group: ratbox_group,
        pid_file: "#{ratbox_path}/etc/ircd.pid",
        start: "#{ratbox_path}/bin/ircd",
        stop: "/bin/kill -9 `cat #{ratbox_path}/etc/ircd.pid`",
        watch_files: [
          { name: 'ircd.conf', path: "#{ratbox_path}/etc/ircd.conf" }
        ]
      }
    )
  end

  it 'should configure monit to launch ratbox-services' do
    services_pid = "#{services_path}/var/run/ratbox-services.pid"
    services_start = "#{services_path}/sbin/ratbox-services"
    services_stop = "/bin/kill -9 `cat #{services_pid}`"

    expect(chef_run).to create_template(
      '/etc/monit/conf.d/ratbox-services.monit.conf'
    ).with(
      source: 'monit.service.conf.erb',
      owner: 'root',
      group: 'root',
      mode: 0750,
      variables: {
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
      }
    )
  end

  it 'should install the kiwiirc monit wrapper' do
    expect(chef_run).to create_template(
      "#{kiwi_path}/monit-wrapper.sh"
    ).with(
      source: 'monit-wrapper.sh.erb',
      owner: kiwi_user,
      group: kiwi_group,
      mode: 0750,
      variables: {
        home: kiwi_path,
        command: "#{kiwi_path}/kiwi"
      }
    )
  end

  it 'should configure monit to launch kiwiirc' do
    config_file = "#{kiwi_path}/config.js"
    pid_file = "#{kiwi_path}/kiwiirc.pid"
    kiwi_wrapper = "#{kiwi_path}/monit-wrapper.sh"
    kiwi_build = "#{kiwi_wrapper} build"
    kiwi_start = "#{kiwi_wrapper} start -c #{config_file} -p #{pid_file}"
    kiwi_stop = "#{kiwi_wrapper} stop"

    expect(chef_run).to create_template(
      '/etc/monit/conf.d/kiwiirc.monit.conf'
    ).with(
      source: 'monit.service.conf.erb',
      owner: 'root',
      group: 'root',
      mode: 0750,
      variables: {
        name: 'kiwiirc',
        user: kiwi_user,
        group: kiwi_group,
        pid_file: "#{pid_file}",
        start: "/bin/bash -c '#{kiwi_build} && #{kiwi_start}'",
        stop: "#{kiwi_stop}",
        watch_files: [
          {
            name: 'config.js',
            path: "#{config_file}"
          }
        ]
      }
    )
  end

  it 'should install the hubot monit wrapper' do
    hubot_path = "/home/#{hubot_name}"

    expect(chef_run).to create_template(
      "#{hubot_path}/monit-wrapper.sh"
    ).with(
      source: 'monit-wrapper.sh.erb',
      owner: hubot_name,
      group: hubot_name,
      mode: 0750,
      variables: {
        home: hubot_path,
        command: "#{hubot_path}/hubot.sh"
      }
    )
  end

  it 'should configure monit to launch hubot' do
    hubot_path = "/home/#{hubot_name}"
    hubot_pid = "#{hubot_path}/#{hubot_name}.pid"
    hubot_start = "#{hubot_path}/monit-wrapper.sh start"
    hubot_stop = "#{hubot_path}/monit-wrapper.sh stop"

    expect(chef_run).to create_template(
      "/etc/monit/conf.d/#{hubot_name}.monit.conf"
    ).with(
      source: 'monit.service.conf.erb',
      owner: 'root',
      group: 'root',
      mode: 0750,
      variables: {
        name: hubot_name,
        user: hubot_name,
        group: hubot_name,
        pid_file: hubot_pid,
        start: hubot_start,
        stop: hubot_stop,
        watch_files: [
          {
            name: '.hubotrc',
            path: "#{hubot_path}/.hubotrc"
          }
        ]
      }
    )
  end
end
