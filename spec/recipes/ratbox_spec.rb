# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::ratbox' do
  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include ircd-ratbox' do
    expect(chef_run).to include_recipe 'ircd-ratbox'
  end

  it 'should configure ircd-ratbox' do
    expect(chef_run).to create_template('/home/ratbox/etc/ircd.conf').with(
      mode: 0644,
      source: 'ratbox.conf.erb'
    )
  end

  it 'should configure ratbox-services' do
    expect(chef_run).to create_template(
      '/home/ratbox-services/etc/ratbox-services.conf'
    ).with(
      mode: 0644,
      source: 'ratbox-services.conf.erb'
    )
  end

  it 'should generate the ratbox-services schemas' do
    command = './generate-schema.pl'
    expect(chef_run).to run_bash(command).with(
      code: command,
      cwd: '/home/ratbox-services/src/tools',
      user: 'ratbox-services',
      group: 'ratbox-services'
    )
  end

  it 'should initialize the ratbox-services database' do
    prefix = '/home/ratbox-services'
    db_file = "#{prefix}/etc/ratbox-services.db"
    schema_file = "#{prefix}/src/tools/schema-sqlite.txt"
    command = "./sqlite3 #{db_file} < #{schema_file}"
    expect(chef_run).to run_bash(command).with(
      code: command,
      cwd: '/home/ratbox-services/bin',
      user: 'ratbox-services',
      group: 'ratbox-services'
    )
  end
end
