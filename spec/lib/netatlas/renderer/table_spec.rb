require 'spec_helper'

describe NetAtlas::Renderer::Table do
  subject { NetAtlas::Renderer::Table.new([
    {:foo => "stuff", :bar => 3.2, :baz =>  "more stuff"},
    {:foo => "stuff", :bar => 3.2, :baz =>  "and some shit"}],
   :foo, {:field => :baz, :color => :red}, :bar) 
  }
  it "should render a table" do  
    subject.render.should include("more stuff")
  end
end