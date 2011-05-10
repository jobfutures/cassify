require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cassify::Errors::Base do
  it "should be able to initialize" do
    error = Cassify::Errors::Base.new("code", "string")
  end
end