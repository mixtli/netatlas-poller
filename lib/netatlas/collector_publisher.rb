require 'netatlas/publisher'
class NetAtlas::CollectorPublisher < NetAtlas::Publisher
  def initialize 
    super('collector_queue')
  end
end
