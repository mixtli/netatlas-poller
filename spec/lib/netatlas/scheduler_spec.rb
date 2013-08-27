require 'spec_helper'
require 'netatlas/scheduler'

describe NetAtlas::Scheduler do
  it "should schedule data_sources" do
    NetAtlas::Poller.stub(:instance => NetAtlas::Poller.new)
    sources = {
        1 => NetAtlas::Resource::DataSource.new(:id => 1,:interval => 60, :ip_address => '74.125.224.80',:plugin_name => 'Ping'), 
        2 => NetAtlas::Resource::DataSource.new(:id => 2,:interval => 60, :ip_address => '127.0.0.1',:plugin_name => 'Ping')
    }
    NetAtlas::Poller.instance.should_receive(:get_data_sources).and_return(sources)
    subject.wrapped_object.should_receive(:schedule).with(sources[1])
    subject.wrapped_object.should_receive(:schedule).with(sources[2])
    subject.run
  end

end
