# -*- encoding: utf-8 -*-
require File.expand_path('../lib/netatlas/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["mixtli"]
  gem.email         = ["ronmcclain75@gmail.com"]
  gem.description   = %q{Netatlas poller}
  gem.summary       = %q{Netatlas poller}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.bindir        = 'bin'
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "netatlas-poller"
  gem.require_paths = ["lib"]
  gem.has_rdoc      = true
  gem.extra_rdoc_files = ['README.rdoc', 'netatlas.rdoc']
  gem.rdoc_options << '--title' << 'todo' << '--main' << 'README.rdoc' << '-ri'
  gem.version       = NetAtlas::VERSION

  gem.add_dependency "daemons"
  #gem.add_dependency "activeresource"
  gem.add_dependency 'amqp'  #,  '0.7.4'
  gem.add_dependency 'eventmachine', '~> 1.0.0.beta.4'
  gem.add_dependency 'faraday'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'activesupport', '~> 3.2.0'
  #gem.add_dependency 'rbcurse', :github => 'krumar/rbcurse'
  gem.add_dependency "net-snmp"
  gem.add_dependency  'command_line_reporter'
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rdoc')
  gem.add_runtime_dependency('gli', '2.0.0.rc4')  
end
