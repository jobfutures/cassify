require 'spec_helper'

describe Cassify::ServiceTicket do
  it "should be consumable" do
    ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "localhost")
    service_ticket = Cassify::ServiceTicket.generate!("http://localhost:3000", "user@user.com", "localhost", ticket_granting_ticket)
    Cassify::ServiceTicket.validate("http://localhost:3000", service_ticket.to_s).should be_true
    service_ticket.consume!
    lambda { Cassify::ServiceTicket.validate("http://localhost:3000", service_ticket.to_s) }.should raise_error
  end

  it "should be expirable" do
    login_ticket = Cassify::LoginTicket.generate!("http://localhost:3000")
    login_ticket.update_attribute(:created_on, Time.now - 2.days)
    login_ticket.expired?.should be_true
    lambda { Cassify::LoginTicket.validate(login_ticket.to_s) }.should raise_error
  end

  it "should have to_s method" do
    ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "localhost")
    Cassify::ServiceTicket.generate!("http://localhost:3000", "user@user.com", "localhost", ticket_granting_ticket).to_s.should match /^ST-/
  end
end
