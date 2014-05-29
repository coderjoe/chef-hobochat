# Encoding: utf-8
# Cookbook Name:: hobochat
# Recipe:: default

include_recipe 'apt'
include_recipe 'hobochat::ratbox'
include_recipe 'hobochat::kiwiirc'
include_recipe 'hobochat::hubot'
include_recipe 'hobochat::monit'
