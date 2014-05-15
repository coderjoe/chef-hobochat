# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::default' do
  let(:chef_run) do
    stub_command("/usr/local/bin/npm -v 2>&1 | grep '1.3.5'").and_return('')
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'should include ircd-ratbox' do
    expect(chef_run).to include_recipe 'ircd-ratbox'
  end

  it 'should include kiwiirc' do
    expect(chef_run).to include_recipe 'kiwiirc'
  end
end
