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

  it "should discover device from the queue", :vcr do
    command_msg = {
      'id' => 1,
      'name' => 'scan',
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
      NetAtlas::Plugin::SNMP.any_instance.should_receive(:do_scan).once.and_return(true)
      subject.amq.direct("").publish(command_msg.to_json, :routing_key => "command_#{subject.id}")
      queue = subject.amq.queue('command_result', :durable => true)
      queue.subscribe do |hdr, msg|
        msg = JSON.parse(msg)
        msg.should include( 
          'id' => 1,
          'result' => true
        )
        hdr.ack
        done { queue.unsubscribe; queue.delete }
      end
    end
  end

  it "should discover device with snmp from the queue", :vcr, :focus do
    puts "in tets"
    command_msg = {
      'id' => 1,
      'name' => 'scan',
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
      #NetAtlas::Plugin::SNMP.any_instance.should_receive(:do_scan).once.and_return(true)
      subject.amq.direct("").publish(command_msg.to_json, :routing_key => "command_#{subject.id}")
      
      queue = subject.amq.queue('event_queue', :durable => true).bind(subject.event_exchange)
      queue.subscribe do |hdr, msg|
        msg = JSON.parse(msg) 
        msg.should include(
          'type' => 'discover',
          'arguments' => {
            'type' => 'interface',
            'ip_address' => '127.0.0.1',
            'snmp_index' => '1'
          }
        )
        hdr.ack
        done {queue.unsubscribe; queue.delete }
      end
    end
  end

  it "should poll a service" do
    async do
      ds = NetAtlas::Resource::DataSource.new :ip_address => '127.0.0.1', :plugin_name => 'Ping'
      result = subject.poll(ds)
      result.should be_kind_of(NetAtlas::Result)
      result.value.should be_kind_of(Float)
      result.value.should be > 0
    end
  end

  it "should schedule and run polls" do
    described_class.stub(:instance =>  described_class.new) 
    async do
      sources = {
        1 => NetAtlas::Resource::DataSource.new(:id => 1,:ip_address => '74.125.224.80',:plugin_name => 'Ping'), 
        2 => NetAtlas::Resource::DataSource.new(:id => 2,:ip_address => '127.0.0.1',:plugin_name => 'Ping')
      }
      subject.should_receive(:get_data_sources).and_return(sources)
      subject.do_scheduler
      subject.stub(:post)
      result = subject.next_poll(false)
      result2 = subject.next_poll(false)
      result.should be_kind_of NetAtlas::Result
      result2.should be_kind_of NetAtlas::Result
    end
  end
end
