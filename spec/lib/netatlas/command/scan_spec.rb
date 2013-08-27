require 'spec_helper'

describe NetAtlas::Command::Scan do

  it "should create a valid scan command" do
    cmd = NetAtlas::Command.create(:name => 'scan', :arguments => {'device' => {'ip_address' => '127.0.0.1'}}, 'id' => 2)
    cmd.should be_kind_of(NetAtlas::Command::Scan)
  end

  it "should discover a device" do
    cmd = NetAtlas::Command.create(:name => 'scan', :arguments => {'device' => {'ip_address' => '127.0.0.1'}}, 'id' => 2)

    NetAtlas::PollerGroup.supervise_as :poller_group
    NetAtlas::PollerGroup.run!
    sleep 1

    Celluloid::Actor[:event_publisher].should_receive(:publish).with(an_instance_of(NetAtlas::Resource::Event)).at_least(1).times
      result = cmd.process!
    Celluloid::Actor[:poller_group].terminate
  end

end
