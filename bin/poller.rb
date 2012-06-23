require 'rubygems'
#$LOAD_PATH << "../lib"
require 'netatlas'

#poller = NetAtlas::Poller.singleton

poller = NetAtlas::Poller.new
poller.configure
poller.run

