require 'netatlas/publisher'
class NetAtlas::EventPublisher < NetAtlas::Publisher
  attr_accessor :channel
  def initialize
    super('event_queue')
  end
end
