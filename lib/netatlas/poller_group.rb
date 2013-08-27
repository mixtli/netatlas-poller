require 'netatlas/command_listener'
require 'netatlas/event_publisher'
require 'netatlas/collector_publisher'
require 'netatlas/scheduler'
require 'netatlas/worker'
class NetAtlas::PollerGroup < Celluloid::SupervisionGroup
  supervise NetAtlas::CommandListener, :as => :command_listener
  supervise NetAtlas::EventPublisher, :as => :event_publisher
  supervise NetAtlas::CollectorPublisher, :as => :collector_publisher
  supervise NetAtlas::Scheduler, :as => :scheduler
  pool NetAtlas::Worker, :as => :worker_pool
end
