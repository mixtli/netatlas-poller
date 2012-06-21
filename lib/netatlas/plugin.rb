module NetAtlas
  module Plugin
    class Base
      def scan(device, arguments = nil)
        do_scan(device, arguments)
      end
      def do_scan
        raise NetAtlas::Error, "must override do_scan in base class"
      end
    end
  end
end
