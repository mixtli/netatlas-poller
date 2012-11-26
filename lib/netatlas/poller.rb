require 'netatlas/client'
require 'netatlas/resource'
require 'fiber'
class NetAtlas::Poller < NetAtlas::Resource::Base
  attr_reader :amq
  self.uri = '/pollers'
  self.schema = {:id => Integer, :hostname => String}

  def self.instance
    @@instance ||= nil
    return @@instance if @@instance
    poller_id = File.read('/etc/netatlas/poller.id') rescue nil
    if poller_id
     @@instance ||= self.get(poller_id)
     raise "Failed to find poller with id #{poller_id}" unless @@instance
    else
      @@instance = self.create(:hostname => `hostname`.chomp)
      File.open('/etc/netatlas/poller.id', 'w') {|f| f.write(@@instance.id.to_s) }
    end
    @@instance
  end

  def initialize(args = {})
    super
    @timers = []
    @current_checks = []
    @queue = EM::Queue.new
    @queued = {}
  end

  def run
    EM::run do
      setup
      next_poll
    end
  end

  def setup
    $log.debug "SETUP"
    Net::SNMP::Dispatcher.fiber_loop
    @amq = nil
    @command_queue = nil
    @result_queue = nil
    setup_rabbitmq
    setup_keepalives
    setup_scheduler
    start_command_queue
    setup_rabbitmq_monitor
  end

  def next_poll(runloop = true)
    result = nil
    @queue.pop do |ds|
      @queued[ds.id] = false
      result = poll(ds)
      ds.last_result = result
      post(result)
      next_poll if runloop
    end  
    result
  end

  def poll(ds)
    $log.debug "POLL #{ds.id}"
    plugin = ds.get_plugin
    #f = Fiber.current
    #plugin.poll(ds) do |result|
    #  f.resume(result)
    #end
    #result = Fiber.yield
    plugin.poll(ds)
  end

  def post(result)
    res = {:poller_id => id, :result => result.as_json }
    $log.debug "POST: #{res.inspect}"
    collector_exchange.publish(res.to_json)
  end

  def setup_rabbitmq
    @rabbitmq = AMQP.connect(CONFIG['amqp'].symbolize_keys)
    $log.debug "AMQP SETTINGS: #{CONFIG['amqp'].symbolize_keys}"
    # @rabbitmq.on_disconnection do
    #   exit 2
    # end
    @amq = AMQP::Channel.new(@rabbitmq)
  end

  def setup_scheduler
    @timers << EM::PeriodicTimer.new(10) do
      do_scheduler
    end
  end


  def do_scheduler
    $log.debug "running scheduler"
    data_sources.values.each do |ds|
      last_polled = ds.last_result ? ds.last_result.timestamp : Time.at(0)
      interval = ds.interval || 60
      interval = 30
      if (last_polled + interval.seconds) < Time.now
        $log.debug "scheduling #{ds.id}"
        schedule(ds)
      end
    end
  end 

  def schedule(ds)
    if !@queued[ds.id]
      @queued[ds.id] = true
      @queue.push(ds)
    end 
  end

  def setup_keepalives
    publish_keepalive
    @timers << EM::PeriodicTimer.new(20) do
      if @rabbitmq.connected?
        publish_keepalive
      end
    end
  end
  
  def setup_rabbitmq_monitor
    @timers << EM::PeriodicTimer.new(5) do
      if @rabbitmq.connected?
        unless command_queue.subscribed?
          start_command_queue
        end
      else
        setup_rabbitmq
      end
    end
  end

  def publish_keepalive
    @amq.queue('keepalives').publish({'id' => id, 'timestamp' => Time.now.to_i})
  end

  def configure
    data_sources
  end

  def data_sources
    @data_sources ||= get_data_sources
  end

  def add_data_source(ds)
    @data_sources[ds.id] = ds
  end

  def remove_data_source(ds)
    @data_sources.delete(ds.id)
  end

  def get_data_sources
    sources = {}
    NetAtlas::Resource::DataSource.find(:poller_id => id).each do |ds|
      sources[ds.id] = ds
    end
    sources    
  end

  def start_command_queue
    command_queue.subscribe(:ack => true) do |hdr, msg|
      #begin
      msg = JSON.parse(msg)
      puts "GOT MESSAGE #{msg.inspect}"
      $log.info "COMMAND: #{msg.inspect}"
      command = NetAtlas::Command.create(msg)
      command.process!
      result_queue.publish({:id => command.id, :result => command.result, :error => command.error}.to_json, :mandatory => true)
      hdr.ack
      #rescue => e
      #  $log.error e.message
      #  $log.error e.backtrace
      #end
    end
  end

  def command_queue
    @command_queue ||= @amq.queue("command_#{id}", :durable =>true)
  end

  def result_queue
    @result_queue ||= @amq.queue("command_result", :durable => true)
  end

  def collector_exchange
    @collector_exchange ||= @amq.fanout("collector_exchange", :durable => true)
    @amq.queue("collector_queue", :durable => true).bind(@collector_exchange)
    @collector_exchange
  end

  def event_exchange
    @event_exchange ||= @amq.fanout("event_exchange", :durable => true)
  end

end
