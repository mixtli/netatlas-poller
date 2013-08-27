require 'celluloid'
class NetAtlas::CommandListener
  include Celluloid
  attr_accessor :channel

  def initialize(queue_name = nil) 
    queue_name ||= "command_#{NetAtlas::Poller.instance.id}"
    @queue_name = queue_name
    @mutex = Mutex.new
    @condition = ConditionVariable.new
  end

  def channel
    @channel ||= AMQP::Channel.new
  end

  def queue
    @queue ||= channel.queue(@queue_name, :durable => true)
  end

  def result_exchange
    @result_exchange ||= channel.direct("command_result")
    channel.queue("command_result", :durable => true).bind(@result_exchange, :routing_key => 'command_result')
    @result_exchange
  end

  def start 
    Thread.new do
        queue.subscribe(:ack => true) do |hdr, msg|
          puts "GOT COMMAND #{msg}"
          begin
            msg = JSON.parse(msg)
            command = NetAtlas::Command.create(msg['command'])
            command.process!
            result = {:id => command.id, :result => command.result, :error => command.error}
            puts "RESULT = #{result.inspect}"
            res = result_exchange.publish(result.to_json, :routing_key => 'command_result', :mandatory => true)
            puts "published #{res}"
            hdr.ack
          rescue => e
            puts e.backtrace
            raise "#{e} raising for debugging"
          end
        end
    end
  end
end
