require 'spec_helper'

describe Cassify::CasLog do
  it "should be able to initialize" do
    Cassify::CasLog.instance.should_not be_nil
  end
  
  it "should always have a logger" do
    Cassify::CasLog.log.should_not be_nil
  end
  
  it "should be able to log info" do
    Cassify::CasLog.info("info")
  end
  it "should be able to log warning" do
    Cassify::CasLog.info("warning")
  end
  
  it "should be able to log error" do
    Cassify::CasLog.error("code", "error")
  end
end