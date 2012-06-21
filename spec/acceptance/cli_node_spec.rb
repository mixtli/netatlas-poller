require 'spec_helper'

describe "netatlas node" do
  it "should get list of nodes" do
    10.times { Fabricate(:node) }
    ENV['GLI_DEBUG'] = 'true'
    # run("netatlas_test node list") do |process|
    #   sleep 4
    #   #puts "OUTPUT\n#{process.stdout(false)}"
    #   #puts "ERROR\n#{process.stderr(false)}"
    #   lines = process.stdout(true).split("\n")
    #   lines.size.should eql(23)
    # end
    @aruba_io_wait_seconds = 5
    run_simple("netatlas_test node list", false)
    puts all_stdout
    all_stdout.split("\n").size.should eql(23)
  end
end