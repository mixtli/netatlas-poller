class NetAtlas::Plugin::SNMP < NetAtlas::Plugin::Base
  @sessions = {}
  class << self
    attr_accessor :sessions
  end
  def do_scan(device, arguments)
    session = self.class.sessions[device.ip_address] ||= Net::SNMP::Session.open(:peername => device.ip_address)
    results = {}
    results['ifTable'] = session.columns(['ifIndex', 'ifDescr', 'ifType', 'ifMtu', 'ifSpeed', 'ifPhysAddress', 'ifAdminStatus', 'ifOperStatus', 'ifLastChange'])
    results['ipAddrTable'] = session.columns(['ipAdEntAddr', 'ipAdEntIfIndex', 'ipAdEntNetMask', 'ipAdEntBcastAddr'])
    results['ifXTable'] = session.columns(['ifName', 'ifHighSpeed', 'ifPromiscuousMode', 'ifConnectorPresent', 'ifAlias'])
    results.each do |name, table|
      table.each do |idx, row|
        row.each do |k,v|
          if v.kind_of?(Net::SNMP::OID)
            results[name][idx][k] = v.to_s
          end
        end
      end
    end
    system = session.walk('system')
    results['system'] = {}
    system.each do |k, v|
      results['system'][Net::SNMP::OID.new(k).label] = (v.kind_of?(Net::SNMP::OID) ? v.to_s : v)
    end
    results['ipForwarding.0'] = session.get('ipForwarding.0').varbinds.first.value
    results['hrMemorySize.0'] = session.get('hrSystemNumUsers.0').varbinds.first.value
    results
  end
end
