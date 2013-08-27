module NetAtlas::Resource
  class Event < NetAtlas::Resource::Base
    def publish
      Celluloid::Actor[:event_publisher].publish(self)
    end
  end
end
