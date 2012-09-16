source 'https://rubygems.org'

# Specify your gem's dependencies in netatlas-poller.gemspec
gemspec
gem 'net-snmp' #, :path => '/Users/rmcclain/Projects/net-snmp' #:git => 'git://github.com/mixtli/net-snmp.git'

if ENV['RAILS_ENV'] == 'development'
  gem 'netatlas-client', :path => '/Users/rmcclain/Projects/netatlas-client'
else
  gem 'netatlas-client', :git => 'git@github.com:mixtli/netatlas-client.git' #, :path => '/Users/rmcclain/Projects/netatlas-client'
end


#gem 'rake'
gem 'rspec'
gem 'evented-spec'
gem 'guard'
gem 'guard-rspec'
gem 'guard-ctags-bundler'
gem 'pg'
gem 'sequel'
gem 'vcr'
gem 'fakeweb'
gem 'pry'
gem 'pry-remote'
gem 'pry-stack_explorer'
gem 'pry-debugger'
gem 'database_cleaner'
gem 'fabrication'
gem 'aruba'
gem 'command_line_reporter'
gem 'rbcurse-core', :github => 'rkumar/rbcurse-core'
gem 'simplecov', :require => false