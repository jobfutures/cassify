require 'spec_helper'

describe Cassify::Models::LoginTicket do
  it "should be consumable" do
    login_ticket = Cassify::Models::LoginTicket.generate!("http://localhost:3000")
    login_ticket.consume!
    lambda { Cassify::Models::LoginTicket.validate(login_ticket.to_s) }.should raise_error
  end

  it "should be expirable" do
    login_ticket = Cassify::Models::LoginTicket.generate!("http://localhost:3000")
    login_ticket.expired?.should be_false
    login_ticket.update_attribute(:created_on, Time.now - 2.days)
    login_ticket.expired?.should be_true
    lambda { Cassify::Models::LoginTicket.validate(login_ticket.to_s) }.should raise_error
  end

  it "should have to_s method" do
    Cassify::Models::LoginTicket.generate!("http://localhost:3000").to_s.should match /^LT-/
  end

  it "should cleanup old tickets" do
    login_ticket = Cassify::Models::LoginTicket.generate!("http://localhost:3000")
    login_ticket.update_attribute(:created_on, Time.now - (Cassify::Settings.max_lifetime + 1.week))
    login_ticket.should be_expired
    Cassify::Models::LoginTicket.cleanup.should == 1
  end
end
