# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::default' do
  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include the apt recipe' do
    expect(chef_run).to include_recipe 'apt'
  end

  it 'should include our ratbox recipe' do
    expect(chef_run).to include_recipe 'hobochat::ratbox'
  end

  it 'should include our kiwiirc recipe' do
    expect(chef_run).to include_recipe 'hobochat::kiwiirc'
  end

  it 'should include our hubot recipe' do
    expect(chef_run).to include_recipe 'hobochat::hubot'
  end
end
