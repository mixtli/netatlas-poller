require 'spec_helper'

describe NetAtlas::Plugin::SNMP do
  include EventedSpec::SpecHelper
  it "should poll ifInOctets" do
    ds = NetAtlas::Resource::DataSource.new :ip_address => '127.0.0.1', :arguments => {:oid => 'ifInOctets', :index => 1}
    result = subject.poll(ds)
    result.value.should be_kind_of(Integer)
    result.value.should be > 0
  end
end

