class NetAtlas::Poller < NetAtlas::Resource::Base
  def self.instance
    hostname = CONFIG['hostname'] || `hostname`.chomp
    @@instance ||= self.find(:first, :params => {:hostname => hostname})
  end

  def configure
    data_sources
  end

  def data_sources
    return @data_sources if @data_sources
    @data_sources = get_data_sources
  end

  def get_data_sources
    sources = {}
    NetAtlas::Resource::DataSource.find(:all, :params =>{:poller_id => id} ).each do |ds|
      sources[ds.id] = ds
    end
    sources    
  end

  def start_command_queue
    command_queue.subscribe(:ack => true) do |hdr, msg|
      Fiber.new {
        #begin
          msg = JSON.parse(msg)
          $log.info "COMMAND: #{msg.inspect}"
          command = NetAtlas::Command.create(msg)
          command.process!
          result_queue.publish(command.to_json, :mandatory => true)
        #rescue => e
        #  $log.error e.message
        #  $log.error e.backtrace
        #end
      }.resume(nil)
    end
  end

  def process_command(cmd)
    command = Command.create(cmd)

  end

  def command_queue
    @command_queue ||= AMQP::Channel.new.queue("command_#{id}", :durable =>true)
  end

  def result_queue
    @result_queue ||= AMQP::Channel.new.queue("command_result", :durable => true)
  end

    

end
