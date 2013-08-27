class NetAtlas::Poller < NetAtlas::Resource::Poller
  def self.instance
    self.new(:id => 1, :hostname => 'lvh.me', :ip_address => '127.0.0.1')
  end
end
