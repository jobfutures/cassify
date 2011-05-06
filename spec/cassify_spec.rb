require 'spec_helper'

describe Cassify do
  it "should be valid" do
    Cassify.should be_a(Module)
  end
  
  it "should have a default logger that write to log/Cas.log file" do
    File.open("log/Cas.log", "w")
    Cassify.logger.warn "This is the warning message"
    logoutput = File.read("log/Cas.log")
    logoutput.should include("This is the warning message")
  end
end