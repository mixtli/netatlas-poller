require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'vcr')   
  c.hook_into :faraday
  c.configure_rspec_metadata!
  #c.filter_sensitive_data('<WSDL>') { "http://www.webservicex.net:80/uszip.asmx?WSDL" }
end

RSpec.configure do |c|
  #c.around(:each, :vcr) do |example|
  #  name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
  #  options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
  #  VCR.use_cassette(name, options) { example.call }
  #end
end