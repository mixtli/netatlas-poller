module NetAtlas
  class Resource::DataSource < Resource::Base
    #self.schema = {:ip_address => :string,  :port => :integer, :plugin_name => :string, :arguments => nil, :warning_threshold => :float, :critical_threshold => :float }

    attr_accessor :last_result
    def get_plugin
      @real_plugin ||= eval "NetAtlas::Plugin::#{plugin_name}.new"
    end

    def as_json(options = nil)
      h = super
      # ARes does weird shit with serialized arguments.  
      h['data_source']['arguments'] = arguments.attributes
      h
    end
  end
end

