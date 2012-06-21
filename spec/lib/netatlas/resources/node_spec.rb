require 'spec_helper'

describe NetAtlas::Resource::Node do 
  it "should create a node", :vcr do
    node = NetAtlas::Resource::Node.create(:description => 'foo', :label => 'bar')
    node.id.should be_kind_of(Integer)
  end

  it "should get a node", :vcr => { :record => :once} do
    node = Fabricate(:node, :id => 1, :label => 'foobar')
    #binding.pry
    retreived_node = NetAtlas::Resource::Node.get(node.id)
    retreived_node.id.should eql(node.id)
    retreived_node.label.should eql('foobar')
  end
end
