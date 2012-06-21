module NetAtlas
  module Resource
    class Base 
      class_attribute :base_url
      class_attribute :uri
      attr_accessor :attributes

      self.base_url = ::CONFIG['netatlas_url']
      class << self
        def find(params = {})
          response = conn.get do |req|
            req.url uri
            req.headers['Content-Type'] = 'application/json'
            req.headers['Accept'] = "application/json"
          end
          if response.status == 200
            response.body.map { |attrs| new(attrs)}
          else
            raise "something went wrong"
          end
        end

        def get(id)
          response = conn.get do |req|
            req.url uri + "/#{id}"
            req.headers['Content-Type'] = 'application/json'
            req.headers['Accept'] = "application/json"
          end
          if response.status == 200
            new(response.body)
          else
            raise "something went wrong" 
          end
        end

        def create(params = {})
          response = conn.post do |req|
            req.url uri
            req.headers['Content-Type'] = 'application/json'
            req.headers['Accept'] = "application/json"
            req.body = params.to_json
          end
          if response.status == 201
            new(response.body)
          else
            raise "something went wrong"
          end
        end

        def conn
          @conn ||= Faraday.new(:url => base_url + self.uri) do |c|
            c.request :json
            c.response :json, :content_type => /\bjson$/
            #c.use Faraday::Response::Logger
            c.use FaradayMiddleware::FollowRedirects
            c.adapter  :net_http
          end
        end
      end

      def initialize(attrs = {})
        @attributes = attrs.symbolize_keys
      end
      def [](field)
        @attributes[field]
      end

      def []=(field, val)
        @attributes[field] = val
      end

      def method_missing(m, *args)
        if m.to_s[-1] == '='
          k = m.to_s[0,-1].to_sym
          if @attributes.keys.include?(k)
            @attributes[k] = args[0]
          else
            super
          end
        else
          if @attributes.keys.include?(m)
            @attributes[m]
          else
            super
          end
        end
      end
    end
  end
end

