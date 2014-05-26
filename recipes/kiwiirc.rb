# Encoding: utf-8
# Cookbook Name:: hobochat
# Recipe:: default
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'kiwiirc'

template '/home/kiwiirc/config.js' do
  source 'kiwiirc.config.js.erb'
  owner 'kiwiirc'
  group 'kiwiirc'
  mode 0644
end
