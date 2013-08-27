module NetAtlas
  module Command
    class << self 
      def create(attrs)
        attrs = attrs.symbolize_keys
        if attrs[:name].kind_of?(Symbol)
          attrs[:name] = attrs[:name].to_s
        end
        raise NetAtlas::Command::Error, "invalid id" unless attrs[:id].kind_of?(Integer)
        raise NetAtlas::Command::Error, "invalid command #{attrs[:name]}" unless attrs[:name].kind_of?(String)
        begin
          klass = eval  "#{class_name(attrs[:name])}"
        rescue NameError
          raise NetAtlas::Command::Error, "invalid command #{attrs[:name]}"
        end
        klass.new(attrs)
      end
      def class_name(type)
        "NetAtlas::Command::" + type.to_s.camelize
      end
    end
    
    class Base
      attr_accessor :id, :arguments, :name, :result, :error, :message
      def initialize(attrs)
        @name = attrs[:name]
        @arguments = attrs[:arguments] || {}
        @id = attrs[:id]
        @result = nil
      end

      def process!
        @result = nil
        begin
          @result = do_process
        rescue => e
          @error = e.message
          $log.debug e.message
          $log.debug e.backtrace
          puts e.message
          puts e.backtrace
        end
        puts "DONE process"
        @result
      end

      def do_process
        raise NetAtlas::Command::Error, "must override do_process in subclass"
      end

      def to_json
        {
          :name=> @name,
          :id => @id,
          :result => @result,
          :arguments => @arguments
        }.to_json
      end
    end

    class Error < NetAtlas::Error
    end

  end
end

