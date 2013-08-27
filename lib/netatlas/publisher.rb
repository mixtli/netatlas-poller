require 'celluloid'
class NetAtlas::Publisher
  include Celluloid
  attr_accessor :channel

  def initialize(queue_name)
    @queue_name = queue_name
  end

  def exchange
    channel = AMQP::Channel.new
    @exchange ||= channel.default_exchange 
  end

  def publish(msg)
    EM.schedule do
      exchange.publish(msg.to_json, :routing_key => @queue_name)
    end
  end
end
