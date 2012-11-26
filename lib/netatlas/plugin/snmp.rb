class NetAtlas::Plugin::SNMP < NetAtlas::Plugin::Base
  @sessions = {}
  class << self
    attr_accessor :sessions
  end
  def do_scan(device, arguments)
    puts "in do scan for #{device.ip_address} with #{arguments}"

    session = self.class.sessions[device.ip_address] ||= Net::SNMP::Session.open(:peername => device.ip_address)

    puts "still here"
    results = {}
    results.merge! session.columns(['ifIndex', 'ifDescr', 'ifType', 'ifMtu', 'ifSpeed', 'ifPhysAddress', 'ifAdminStatus', 'ifOperStatus', 'ifLastChange'])
    addr_results = session.columns(['ipAdEntAddr', 'ipAdEntIfIndex', 'ipAdEntNetMask', 'ipAdEntBcastAddr'])

    addr_results.each do |ip, row|
      puts row.inspect
      results[row['ipAdEntIfIndex'].to_s].merge! row
    end
    ifxtable_results = session.columns(['ifName', 'ifHighSpeed', 'ifPromiscuousMode', 'ifConnectorPresent', 'ifAlias'])

    ifxtable_results.each do |idx, row|
      results[idx.to_s].merge! row
    end
    #results.merge! session.columns(['ifIndex'])
    puts "results = #{results.inspect}"
    results.each do |idx, row|
      row.each do |k,v|
        if v.kind_of?(Net::SNMP::OID)
          results[idx][k] = v.to_s
        end
      end
    end

    results.each do |idx, row|
      args = {}
      row.each {|k, v| args["#{k}.#{idx}"] = v }
      event = NetAtlas::Resource::Event.new(:node_id => device.id, :type => 'discover', :arguments => {:type => 'interface', :snmp_index => idx, :ip_address => row['ipAdEntAddr'] }) 
      event.publish
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
