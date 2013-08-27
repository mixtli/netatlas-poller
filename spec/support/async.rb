def async 
  em do
    Fiber.new do
      yield
      done
    end.resume
  end
end

def maxtime(t = 2)
  @timeout_mutex = Mutex.new
  @timeout_condition = ConditionVariable.new
  Timeout::timeout(t) do
    yield
    @timeout_mutex.synchronize { @timeout_condition.wait(@timeout_mutex)}
  end
end

def finish 
  @timeout_mutex.synchronize { @timeout_condition.signal }
end
