class NetAtlas::Worker
  include Celluloid
  include Celluloid::Notifications

  def poll(ds)
    EM.schedule do
      plugin = ds.get_plugin
      result = Fiber.new {
        result = plugin.poll(ds)
        ds.last_result = result
        result.poller_id = NetAtlas::Poller.instance.id
        puts "RESULT: #{result}"
        post(result)
        publish "done_polling", ds
        Fiber.yield result
      }.resume
    end
  end

  def post(result)
    Actor[:collector_publisher].publish(result)
  end
end
