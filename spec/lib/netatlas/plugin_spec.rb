require 'spec_helper'
describe NetAtlas::Plugin::Base do
  specify "scan should raise an error" do
    expect { subject.scan(mock(), mock()) }.to raise_error(NetAtlas::Error)
  end

  specify "poll should raise an error" do
    expect { subject.scan(mock(), mock()) }.to raise_error(NetAtlas::Error) 
  end
end
