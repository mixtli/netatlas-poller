class NetAtlas::Command::Scan < NetAtlas::Command::Base
  def do_process
    snmp_plugin = NetAtlas::Plugin::SNMP.new
    snmp_plugin.scan(NetAtlas::Resource::Device.new(arguments['device'])) 
    {:status => true, :message => "Completed scan of #{arguments['device']['hostname']}"}
  end
end
