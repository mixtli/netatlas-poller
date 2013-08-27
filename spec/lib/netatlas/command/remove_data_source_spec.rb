require 'spec_helper'

describe NetAtlas::Command::RemoveDataSource do
  it "should create a valid remove_data_source command", :vcr do
    NetAtlas::Poller.any_instance.stub(:get_data_sources => {1 => NetAtlas::Resource::DataSource.new(:id => 1)})
    poller = NetAtlas::Poller.new
    NetAtlas::Poller.stub(:instance => poller)
    cmd = described_class.new(:arguments => {'data_source' => {'id' => 1}}, :id => 1)
    lambda do
      cmd.process!
    end.should change { NetAtlas::Poller.instance.data_sources.size }.by(-1)
    cmd.should be_kind_of(NetAtlas::Command::RemoveDataSource)
  end
end
