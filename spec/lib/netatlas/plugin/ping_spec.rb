require 'spec_helper'

describe NetAtlas::Plugin::Ping do
  include EventedSpec::SpecHelper
  it "should ping a host" do
    async do
      ds = NetAtlas::Resource::DataSource.new :ip_address => '127.0.0.1'
      result = subject.poll(ds)
      result.value.should be_kind_of(Float)
      result.value.should be > 0
    end
  end
end
