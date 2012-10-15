require 'netatlas/plugin/nagios'
class NetAtlas::Plugin::HTTP < NetAtlas::Plugin::Nagios
  self.check_script = 'check_http'
  self.perf_field = 'time'
end
