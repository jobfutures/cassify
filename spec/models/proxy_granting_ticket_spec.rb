require 'spec_helper'

describe Cassify::Models::ProxyGrantingTicket do
  it "should have to_s method" do
    Cassify::Models::ProxyGrantingTicket.generate!("http://localhost:3000").to_s.should match /^LT-/
  end
end
