class NetAtlas::Command::RemoveDataSource < NetAtlas::Command::Base
  def do_process
    data_source = NetAtlas::Resource::DataSource.new(arguments['data_source'])
    puts NetAtlas::Poller.instance.data_sources.inspect
    NetAtlas::Poller.instance.remove_data_source(data_source)
    true
  end
end
