class NetAtlas::Plugin::Nagios < NetAtlas::Plugin::Base
  SEVERITIES = [:ok, :warning, :critical, :unknown, :error]
  class << self
    attr_accessor :check_script, :perf_field
  end
  self.argument_types = {
    additional_arguments: { type: String }
  }

  def do_scan(device, arguments = {})
    raise NetAtlas::Error, "do_scan not implemented for Nagios"
  end

  def do_poll(data_source, &block)
    cmd = "#{CONFIG[:nagios][:plugin_dir]}/#{self.class.check_script} " 
    cmd += build_args(data_source)
    $log.debug "NAGIOS: #{cmd}"
    EM.system(cmd) { |output, status|
      value = get_value(output, status)
      block.call NetAtlas::Result.new :data_source => data_source, :value => value, :state => SEVERITIES[status.exitstatus].to_s, :additional => output
    }
  end

  def build_args(data_source)
    args = ["-H #{data_source.ip_address}"]
    args << ["-p #{data_source.port}"] if data_source.port
    arguments = data_source.arguments || {}
    arguments.each do |k, v|
      key = "--" + k.to_s.gsub("_", "-")
      if v == true
        args << key
      else
        args << "#{key} #{v}" if v  
      end
    end
    args.join(" ")
  end

  def get_value(output, status)
    output, perfdata = output.split('|')
    return nil unless perfdata
    metrics = {}
    stuff = perfdata.scan(/(\w+)=([\d|\.]+)/)
    stuff.each {|i| metrics[i[0]] = i[1]}
    metrics[self.class.perf_field].to_f
  end
end
