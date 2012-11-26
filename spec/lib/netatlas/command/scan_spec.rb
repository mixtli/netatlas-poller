require 'spec_helper'

describe NetAtlas::Command::Scan do

  it "should create a valid scan command" do
    cmd = NetAtlas::Command.create(:name => 'scan', :arguments => {'device' => {'ip_address' => '127.0.0.1'}}, 'id' => 2)
    cmd.should be_kind_of(NetAtlas::Command::Scan)
  end

end
