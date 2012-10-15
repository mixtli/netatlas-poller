def async 
  em do
    Fiber.new do
      yield
      done
    end.resume
  end
end
