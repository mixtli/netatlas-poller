require 'rubygems'
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'netatlas'

#poller = NetAtlas::Poller.singleton

poller = NetAtlas::Poller.new
poller.configure
poller.run

