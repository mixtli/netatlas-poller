class NetAtlas::Plugin::SNMP < NetAtlas::Plugin::Base
  @sessions = {}
  class << self
    attr_accessor :sessions
  end
  def get_session(ip)
    self.class.sessions[ip] ||= Net::SNMP::Session.open(:peername => ip)
  end
  def do_scan(device, arguments)
    puts "in do scan for #{device.ip_address} with #{arguments}"

    session = get_session(device.ip_address)
    results = {}
    results.merge! session.columns(['ifIndex', 'ifDescr', 'ifType', 'ifMtu', 'ifSpeed', 'ifPhysAddress', 'ifAdminStatus', 'ifOperStatus', 'ifLastChange'], :blocking => true)
    addr_results = session.columns(['ipAdEntAddr', 'ipAdEntIfIndex', 'ipAdEntNetMask', 'ipAdEntBcastAddr'], :blocking => true)

    addr_results.each do |ip, row|
      results[row['ipAdEntIfIndex'].to_s].merge! row
    end
    ifxtable_results = session.columns(['ifName', 'ifHighSpeed', 'ifPromiscuousMode', 'ifConnectorPresent', 'ifAlias'], :blocking => true)

    ifxtable_results.each do |idx, row|
      results[idx.to_s].merge! row
    end
    #results.merge! session.columns(['ifIndex'])
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

    system = session.walk('system', :blocking => true)
    results['system'] = {}
    system.each do |k, v|
      results['system'][Net::SNMP::OID.new(k).label] = (v.kind_of?(Net::SNMP::OID) ? v.to_s : v)
    end
    results['ipForwarding.0'] = session.get('ipForwarding.0', :blocking => true).varbinds.first.value
    results['hrMemorySize.0'] = session.get('hrSystemNumUsers.0', :blocking => true).varbinds.first.value
    results
  end

  def do_poll(ds)
    puts "IN SNMP POLL #{ds.id}"
    session = get_session(ds.ip_address)    
    oid = ds.arguments[:oid]
    if ds.node.snmp_index
      oid = "#{oid}.#{ds.node.snmp_index}"
    end
    state = :ok
    value = nil
    err = nil
    begin
      pdu = session.get(oid)
      if pdu.error?
        state = :error
        err = pdu.error_message
        value = nil
      else
        value = pdu.varbinds.first.value
      end
    rescue => e
      state = :error
      puts e.message
    end

    res = NetAtlas::Result.new :data_source_id => ds.id, :value => value, :state => state, :additional => err 
    res
  end
end
