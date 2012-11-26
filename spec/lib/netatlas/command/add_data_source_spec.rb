require 'spec_helper'

describe NetAtlas::Command::AddDataSource do

  it "should create a valid add_data_source command" do
    poller = NetAtlas::Poller.new
    poller.stub(:get_data_sources => {})
    NetAtlas::Poller.stub(:instance => poller)
    cmd = NetAtlas::Command.create('name' => 'add_data_source', 'arguments' => {'data_source' => {'id' => 1}}, 'id' => 1)
    lambda do
      cmd.process!
    end.should change { NetAtlas::Poller.instance.data_sources.size }.by(1)
    cmd.should be_kind_of(NetAtlas::Command::AddDataSource)
  end
end
