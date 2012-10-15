class NetAtlas::Command::AddDataSource < NetAtlas::Command::Base
  def do_process
    data_source = NetAtlas::Resource::DataSource.new(arguments['data_source'])
    NetAtlas::Poller.instance.add_data_source(data_source)
    true
  end
end
