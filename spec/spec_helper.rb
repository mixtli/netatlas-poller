# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
require 'simplecov'
require 'fabrication'
require 'rspec'
require 'sequel'
require 'database_cleaner'
require 'pry'
require 'evented-spec'
require 'database_cleaner'
require 'aruba/api'
require 'rabbit_manager'


ENV['NETATLAS_ENV'] = 'test'

Thread.abort_on_exception = true

SimpleCov.start if File.basename($0) == 'rspec'

DB = Sequel.connect('postgres://postgres@localhost/netatlas_test')
require 'netatlas'
require 'mocks/poller_mock'
require 'netatlas/factories'
Dir['./spec/support/*.rb'].map {|f| require f}

NetAtlas.setup(:url => 'http://test.netatlas.lvh.me', :user => 'admin@netatlas.com', :password => 'password')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Aruba::Api, :example_group => {
    :file_path => /spec\/acceptance/
  }
  #config.mock_framework = :mocha
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do 
    EM.stop if EM.reactor_running?
    rabbit = RabbitManager.new("http://guest:guest@localhost:55672")
    begin
      rabbit.delete_vhost("netatlas_test")
    rescue
    end
    rabbit.add_vhost("netatlas_test")
    rabbit.add_permission("netatlas", {'read' => '.*', 'write' => '.*', 'configure' => '.*'}, {:vhost => 'netatlas_test'})
    rabbit.add_permission("guest", {'read' => '.*', 'write' => '.*', 'configure' => '.*'}, {:vhost => 'netatlas_test'})
    DatabaseCleaner.clean
    Fabricate(:admin)
  end

  config.after(:each) do
  end
end
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
