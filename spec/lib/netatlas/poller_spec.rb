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

  it "should gather configuration information" do
    subject.stub!(:get_data_sources).and_return({
      1 => NetAtlas::Resource::DataSource.new(ip_address: '127.0.0.1', plugin_name: 'HTTP'),
      2 => NetAtlas::Resource::DataSource.new(ip_address: '127.0.0.1', plugin_name: 'SSH')
    })

    subject.configure
    subject.ip_address.should eql('127.0.0.1')
    subject.data_sources.count.should == 2
  end

  let(:command_msg) {{
    'id' => 1,
    'command' => 'scan',
    'arguments' => {
      'device' => {
        'id' => 1,
        'ip_address' => '127.0.0.1',
        'hostname' => 'lvh.me'
      }
    }
  }}

  it "should discover device from the queue" do
    amqp do
     # Net::SNMP::Dispatcher.run_loop
      subject.start_command_queue
      AMQP::Channel.new do |channel|
        NetAtlas::Plugin::SNMP.any_instance.should_receive(:do_scan).once.and_return({'foo' => 'bar'})
        channel.direct("").publish(command_msg.to_json, :routing_key => "command_#{subject.id}")
        queue = channel.queue('command_result', :durable => true)
        queue.subscribe do |hdr, msg|
          msg = JSON.parse(msg)
          msg.should eql(command_msg.merge({
            'result' => {
              'status' => true,
              'message' => 'Completed scan of lvh.me'
            }
          }))
          done { queue.unsubscribe; queue.delete }
        end
      end
    end
  end
end
