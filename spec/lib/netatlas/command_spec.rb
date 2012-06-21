require 'spec_helper'

describe NetAtlas::Command do
  it "should instantiate a new command from a struct" do
    cmd = NetAtlas::Command.create('command' => 'scan', 'arguments' => {'ip_address' => '127.0.0.1'}, 'id' => 2)
    cmd.should be_kind_of(NetAtlas::Command::Scan)
  end

  it "should require id" do
    lambda {
      NetAtlas::Command.create('command' => 'scan', 'arguments' => {'ip_address' => '127.0.0.1'})
    }.should raise_error(NetAtlas::Command::Error, /invalid id/i)
  end

  it "should require command" do
    lambda {
      NetAtlas::Command.create('arguments' => {'ip_address' => '127.0.0.1'}, 'id' => 1)
    }.should raise_error(NetAtlas::Command::Error, /invalid command/)
  end

  it "should require valid command" do
    lambda {
      NetAtlas::Command.create('command' => 'doesntexist', 'id' => 1)
    }.should raise_error(NetAtlas::Command::Error, /invalid command/)
  end
end
