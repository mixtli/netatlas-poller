require 'spec_helper'

describe NetAtlas::Poller do
  include EventedSpec::SpecHelper
  subject { NetAtlas::Poller.instance }

  default_timeout 5.0 
  default_options CONFIG['amqp']

  amqp_before do
    AMQP::Channel.new do |channel|
      channel.queue("command_#{subject.id}", :durable => true).purge 
      channel.queue('command_result', :durable => true).purge
    end
  end
  before do
    Fabricate(:test_user)
    begin
      FileUtils.rm('/etc/netatlas/poller.id') 
    rescue
    end
  end

  it "should register itself", :vcr do
    puts ::CONFIG.inspect
    instance = described_class.instance
    instance.hostname.should eql(`hostname`.chomp)
    File.read('/etc/netatlas/poller.id').should eql(instance.id.to_s)
  end

  it "should gather configuration information", :vcr do
    2.times { Fabricate(:data_source) }
    5.times do
      Fabricate(:data_stream, :poller_id => subject.id)
    end
    subject.configure
    subject.data_sources.count.should == 5
  end

  it "should discover device from the queue" do
    command_msg = {
      'id' => 1,
      'command' => 'scan',
      'arguments' => {
        'device' => {
          'id' => 1,
          'ip_address' => '127.0.0.1',
          'hostname' => 'lvh.me'
        }
      }
    }

    amqp do
     # Net::SNMP::Dispatcher.run_loop
      subject.setup
      NetAtlas::Plugin::SNMP.any_instance.should_receive(:do_scan).once.and_return({'foo' => 'bar'})
      subject.amq.direct("").publish(command_msg.to_json, :routing_key => "command_#{subject.id}")
      queue = subject.amq.queue('command_result', :durable => true)
      queue.subscribe do |hdr, msg|
        msg = JSON.parse(msg)
        msg.should eql(command_msg.merge({
          'result' => {
            'status' => true,
            'message' => 'Completed scan of lvh.me'
          }
        }))
        hdr.ack
        done { queue.unsubscribe; queue.delete }
      end
    end
  end
end
