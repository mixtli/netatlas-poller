require 'spec_helper'
Thread.abort_on_exception = true
describe NetAtlas::Poller do
  include EventedSpec::SpecHelper
  subject { NetAtlas::Poller.instance }

  before do
    Fabricate(:test_user)
    begin
      Poller.instance_variable_set :@instance,  nil
      FileUtils.rm('/etc/netatlas/poller.id') 
    rescue
    end
  end

  it "should create a poller" do
    NetAtlas::Resource::Poller.create(:hostname => 'foo.lvh.me')
    described_class.all.size.should == 1
  end

  xit "should register itself", :vcr do
    instance = described_class.instance
    instance.hostname.should eql(`hostname`.chomp)
    puts instance.inspect
    File.read('/etc/netatlas/poller.id').should eql(instance.id.to_s)
  end

  it "should gather configuration information" do
    2.times { Fabricate(:data_source) }
    5.times do
      Fabricate(:data_stream, :poller_id => subject.id)
    end
    subject.data_sources.count.should == 5
  end
end
