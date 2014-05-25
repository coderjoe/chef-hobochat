# Encoding: utf-8
require 'spec_helper'

describe 'hobochat::default' do
  %w(ratbox ratbox-services).each do |cred|
    describe user(cred) do
      it { should exist }
      it { should have_home_directory "/home/#{cred}" }
      it { should have_login_shell '/bin/false' }
    end

    describe group(cred) do
      it { should exist }
    end
  end

  %w(/home/ratbox /home/ratbox-services).each do |dir|
    describe file(dir) do
      it { should be_directory }
    end

    describe file("#{dir}/etc") do
      it { should be_directory }
    end

    describe file("#{dir}/bin") do
      it { should be_directory }
    end
  end

  %w( /home/ratbox/bin/ircd
      /home/ratbox/etc/ircd.conf
      /home/ratbox-services/sbin/ratbox-services
      /home/ratbox-services/etc/ratbox-services.conf
      /home/ratbox-services/etc/ratbox-services.db
  ).each do |dir|
    describe file(dir) do
      it { should be_file }
    end
  end
end
