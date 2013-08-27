require 'spec_helper'
require 'netatlas/worker'
require 'netatlas/collector_publisher'

describe NetAtlas::Worker do
  it "should poll a datasource" do
    ds = NetAtlas::Resource::DataSource.new :ip_address => '127.0.0.1', :plugin_name => 'Ping', :arguments => {}
    NetAtlas::CollectorPublisher.supervise_as :collector_publisher
    Celluloid::Actor[:collector_publisher].run
    result = subject.poll(ds)
    result.should be_kind_of(NetAtlas::Result)
    result.value.should be_kind_of(Float)
    result.value.should be > 0
  end
end
