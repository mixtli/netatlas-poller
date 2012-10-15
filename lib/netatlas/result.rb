class NetAtlas::Result
  STATUSES = [:ok, :warning, :critical, :unknown, :error]
  attr_accessor :state, :value, :additional, :timestamp, :data_source

  def initialize(args)
    @state = args[:state].to_s
    @value = args[:value]
    @additional = args[:additional]
    @data_source = args[:data_source]
  end

  def to_s
    "#{@state} #{@value} #{@additional}"
  end

  def to_json
    {:state => @state, :additional => @additional, :value => @value, :data_source_id => @data_source_id}.to_json
  end
end
