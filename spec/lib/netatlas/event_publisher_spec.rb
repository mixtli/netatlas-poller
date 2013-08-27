require "spec_helper"
require "netatlas/event_publisher"
Thread.abort_on_exception = true

describe NetAtlas::EventPublisher do
  it "should publish an event" do
    subject.run
    publisher = subject
    maxtime(2) do 
      AMQP::Channel.new do |channel|
        queue = channel.queue("event_queue")
        queue.subscribe do |hdr, msg|
          finish
        end
        EM.next_tick { publisher.publish({'a' => 'b'}) }
      end
    end
  end
end
