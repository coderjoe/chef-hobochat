# Encoding: utf-8
name 'hobochat'
maintainer 'Joe Bauser'
maintainer_email 'coderjoe@coderjoe.net'
license 'All rights reserved'
description 'Installs/Configures hobochat'
long_description 'Installs/Configures hobochat'
version '0.1.0'

%w(apt openssl nodejs ircd-ratbox kiwiirc).each do |dep|
  depends dep
end
