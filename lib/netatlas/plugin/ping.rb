require 'netatlas/plugin/nagios'
class NetAtlas::Plugin::Ping < NetAtlas::Plugin::Nagios
  self.check_script = 'check_icmp'
  self.perf_field = 'rta'
end
