module NetAtlas::Resource
  class Event < NetAtlas::Resource::Base
    def publish
      poller = NetAtlas::Poller.instance
      poller.event_exchange.publish(self.to_json) 
    end
  end
end
