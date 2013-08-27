require 'spec_helper'
require 'netatlas/command_listener'

describe NetAtlas::CommandListener do
  subject { described_class.new("command_queue").wrapped_object}
  it "should send a result" do
    subject.run
    maxtime do
      NetAtlas::Command::Scan.any_instance.stub(:do_process => true)
      subject.queue.publish({'id' => 1, 'name' => 'scan'}.to_json)
      subject.result_queue.subscribe(:ack => true) do |hdr, msg|
        msg = JSON.parse(msg) 
        msg['id'].should == 1
        msg['result'].should be_true
        msg['error'].should be_nil
        finish   
      end
    end
  end
end

