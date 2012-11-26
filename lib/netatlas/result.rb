class NetAtlas::Result
  STATUSES = [:ok, :warning, :critical, :unknown, :error]
  attr_accessor :state, :value, :additional, :timestamp, :data_source_id

  def initialize(args)
    @state = args[:state].to_s
    @value = args[:value]
    @additional = args[:additional]
    @data_source_id = args[:data_source_id]
    @timestamp = args[:timestamp] || Time.now
  end

  def to_s
    "#{@state} #{@value} #{@additional}"
  end

  def as_json
    {:state => @state, :additional => @additional, :value => @value, :data_source_id => @data_source_id}
  end
end
