require 'netatlas/client'
require 'netatlas/resource'
require 'netatlas/resource/poller'
require 'celluloid'
require 'netatlas/command_listener'
require 'netatlas/event_publisher'
require 'her'

class NetAtlas::Poller < NetAtlas::Resource::Poller
  collection_path '/api/pollers'
  resource_path '/api/pollers/:id'

  attr_reader :amq
  def self.instance
    @instance ||= nil
    return @instance if @instance
    poller_id = File.read('/etc/netatlas/poller.id') rescue nil
    if poller_id
     @instance ||= self.find(poller_id)
     raise "Failed to find poller with id #{poller_id}" unless @instance
    else
      @instance = self.create(:hostname => `hostname`.chomp)
      File.open('/etc/netatlas/poller.id', 'w') {|f| f.write(@instance.id.to_s) }
    end
    @instance
  end

  def initialize(args = {})
    super(args)
    @timers = []
    @current_checks = []
    @queue = EM::Queue.new
    @queued = {}
    @data_sources = []
  end

  def data_sources
    if @data_sources.empty? 
      @data_sources = get_data_sources
    else
      @data_sources
    end
  end

  def add_data_source(ds)
    @data_sources[ds.id] = ds
  end

  def remove_data_source(ds)
    @data_sources.delete(ds.id)
  end

  def get_data_sources
    sources = {}
    NetAtlas::Resource::DataSource.all(:poller_id => id).each do |ds|
      sources[ds.id] = ds
    end
    puts "get_data_sources #{sources.inspect}"
    sources    
  end

end
