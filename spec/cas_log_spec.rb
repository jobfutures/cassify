require 'spec_helper'

describe Cassify::CasLog do
  it "should be able to initialize" do
    Cassify::CasLog.instance.should_not be_nil
  end
end