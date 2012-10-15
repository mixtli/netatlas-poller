require 'spec_helper'

describe NetAtlas::Plugin::HTTP do
  include EventedSpec::SpecHelper
  it "should check http" do
    async do
      ds = NetAtlas::Resource::DataSource.new :ip_address => IPSocket.getaddress('www.google.com')
      result = subject.poll(ds)
      result.value.should be_kind_of(Float)
      result.value.should be > 0
    end
  end
end
