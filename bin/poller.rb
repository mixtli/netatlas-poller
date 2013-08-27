require 'rubygems'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'netatlas'
require 'celluloid/autostart'

Thread.abort_on_exception = true

AMQP.start(NETATLAS_CONFIG[:amqp].symbolize_keys) do
  Net::SNMP::Dispatcher.fiber_loop
  NetAtlas::PollerGroup.run!
  Celluloid::Actor[:command_listener].async.start
  Celluloid::Actor[:scheduler].async.start
end

