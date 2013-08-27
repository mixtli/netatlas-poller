class NetAtlas::Command::Scan < NetAtlas::Command::Base
  def do_process
    snmp_plugin = NetAtlas::Plugin::SNMP.new
    raise ArgumentError.new("scan requires device argument") unless arguments['device']
    snmp_plugin.scan(NetAtlas::Resource::Device.new(arguments['device'])) 
    self.message = "Completed scan of #{arguments['device']['hostname']}"
    true
  end
end

