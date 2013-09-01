if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'https://rubygems.org'
# Specify your gem's dependencies in netatlas-poller.gemspec
gemspec
#gem 'net-snmp' #, :path => '/Users/rmcclain/Projects/net-snmp' #:git => 'git://github.com/mixtli/net-snmp.git'

if ENV['NETATLAS_ENV'] == 'development' || ENV['NETATLAS_ENV'] == 'test'
  gem 'net-snmp', :path => '/Users/rmcclain/Projects/net-snmp'
  gem 'netatlas-client', :path => '/Users/rmcclain/Projects/netatlas-client', :require => 'netatlas/client'
  gem 'rabbit_manager', :path => '/Users/rmcclain/Projects/rabbit_manager'
else
  gem 'net-snmp', :git => 'git@github.com:mixtli/net-snmp.git'
  gem 'netatlas-client', :git => 'git@github.com:mixtli/netatlas-client.git' 
  gem 'rabbit_manager', :git => 'git@github.com:mixtli/rabbit_manager.git'
end

gem 'bunny'
gem 'rspec'
gem 'evented-spec'
gem 'guard'
gem 'rb-fsevent'
gem 'guard-rspec'
gem 'guard-ctags-bundler'
gem 'pg'
gem 'sequel'
gem 'vcr'
gem 'fakeweb'
gem 'webmock'
gem 'pry'
gem 'pry-remote'
gem 'pry-stack_explorer'
gem 'pry-debugger'
gem 'database_cleaner'
gem 'fabrication'
gem 'aruba'
gem 'rbcurse-core', :github => 'rkumar/rbcurse-core'
gem 'simplecov', :require => false
gem 'her', :github => 'remiprev/her'
#gem 'mocha', :require => false
