require 'netatlas/poller'
class NetAtlas::Scheduler 
  include Celluloid
  include Celluloid::Notifications

  def initialize
    @queued = {}
    subscribe "done_polling", :done_polling
  end

  def done_polling(queue, ds)
    @queued[ds.id] = false
  end

  def start
    loop do
      do_scheduler
      sleep 10
    end
  end

  def schedule(ds)
    if !@queued[ds.id]
      @queued[ds.id] = true
      Celluloid::Actor[:worker_pool].async.poll(ds)
    end 
  end

  private
  def do_scheduler
    poller = NetAtlas::Poller.instance
    poller.data_sources.values.each do |ds|
      last_polled = ds.last_result ? ds.last_result.timestamp : Time.at(0)
      interval = ds.interval || 60
      interval = 30
      if (last_polled + interval.seconds) < Time.now
        schedule(ds)
      end
    end
  end
end
