# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::hubot' do
  let(:hubot_user) { 'hubot' }
  let(:hubot_dir) { "/home/#{hubot_user}" }
  let(:hubot_repo) { 'https://github.com/example/repo.git' }
  let(:hubot_irc_rooms) { %w(#some #long #list #of #rooms) }
  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new do |node|
      node.set[:hubot][:name] = hubot_user
      node.set[:hubot][:repository] = hubot_repo
      node.set[:hubot][:irc][:rooms] = hubot_irc_rooms
    end.converge(described_recipe)
  end

  it 'should install nodejs' do
    expect(chef_run).to include_recipe('nodejs')
  end

  it 'should install nodejs::npm' do
    expect(chef_run).to include_recipe('nodejs::npm')
  end

  it 'should install redis' do
    expect(chef_run).to install_package('redis-server')
  end

  it 'should create the hubot group' do
    expect(chef_run).to create_group(hubot_user).with(system: true)
  end

  it 'should create the hubot user' do
    expect(chef_run).to create_user(hubot_user).with(
      gid: hubot_user,
      home: hubot_dir,
      shell: '/bin/false',
      system: true
    )
  end

  it 'should create the install directory' do
    expect(chef_run).to create_directory(hubot_dir).with(
      owner: hubot_user,
      group: hubot_user,
      recursive: true,
      mode: 0750
    )
  end

  it 'should clone the hubot repository' do
    expect(chef_run).to sync_git(hubot_dir).with(
      repository: hubot_repo,
      revision: 'master',
      user: hubot_user,
      group: hubot_user
    )
  end

  it 'should create the .hubotrc file' do
    expect(chef_run).to create_template("#{hubot_dir}/.hubotrc").with(
      source: 'hubotrc.erb',
      owner: hubot_user,
      group: hubot_user,
      mode: 0750,
      variables: {
        env: {
          HUBOT_IRC_NICK: hubot_user,
          HUBOT_IRC_SERVER: 'localhost',
          HUBOT_IRC_ROOMS: hubot_irc_rooms,
          HUBOT_IRC_UNFLOOD: 'true'
        }
      }
    )
  end

  it 'should create the hubot launch file' do
    expect(chef_run).to create_template("#{hubot_dir}/hubot.sh").with(
      source: 'hubot.init.erb',
      owner: hubot_user,
      group: hubot_user,
      mode: 0750,
      variables: {
        name: hubot_user,
        directory: hubot_dir
      }
    )
  end
end
