# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::kiwiirc' do
  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include kiwiirc' do
    expect(chef_run).to include_recipe 'kiwiirc'
  end

  it 'should configure kiwiirc' do
    expect(chef_run).to create_template(
      '/home/kiwiirc/config.js'
    ).with(
      source: 'kiwiirc.config.js.erb',
      owner: 'kiwiirc',
      group: 'kiwiirc',
      mode: 0644
    )
  end
end
