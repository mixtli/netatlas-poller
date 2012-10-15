require 'netatlas/result'
module NetAtlas
  module Plugin
    class Base
      class_attribute :argument_types
      self.argument_types = {}
      def scan(device, arguments = nil)
        do_scan(device, arguments)
      end
      def do_scan(device, arguments = {})
        raise NetAtlas::Error, "must override do_scan in base class"
      end
      def poll(data_source, &block)
        result = nil
        f = Fiber.current
        do_poll(data_source) do |result|
          f.resume(result)
        end
        result = Fiber.yield
        result
      end

      def do_poll(data_source)
        raise "Must override do_poll in subclasses"
      end
    end
  end
end
