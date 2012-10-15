module NetAtlas
  module Command
    class << self 
      def create(attrs)
        attrs = attrs.symbolize_keys
        raise NetAtlas::Command::Error, "invalid id" unless attrs[:id].kind_of?(Integer)
        raise NetAtlas::Command::Error, 'invalid command' unless attrs[:command].kind_of?(String)
        begin
          klass = eval  "#{class_name(attrs[:command])}"
        rescue NameError
          raise NetAtlas::Command::Error, "invalid command #{attrs[:command]}"
        end
        klass.new(attrs)
      end
      def class_name(type)
        "NetAtlas::Command::" + type.to_s.camelize
      end
    end
    
    class Base
      attr_accessor :id, :arguments, :command, :result
      def initialize(attrs)
        @command = attrs[:command]
        @arguments = attrs[:arguments]
        @id = attrs[:id]
        @result = {}
      end

      def process!
        @result = do_process
      end

      def do_process
        raise NetAtlas::Command::Error, "must override do_process in subclass"
      end

      def to_json
        {
          :command => @command,
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

