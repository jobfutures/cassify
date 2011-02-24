require 'spec_helper'

describe Cassify::Models::TicketGrantingTicket, "#generate!" do
  it "should return a ticket object" do
    ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "http://localhost:3000", :roles => ["owner", "user"])
    ticket_granting_ticket.to_s.should match /^TGC-/
  end
end

describe Cassify::Models::TicketGrantingTicket, "#validate" do
  it "should return a ticket object if ticket is valid" do
    ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "http://localhost:3000")
    Cassify::Models::TicketGrantingTicket.validate(ticket.ticket).class.should == Cassify::Models::TicketGrantingTicket
  end
  
  it "should raise exception if ticket nil" do
    lambda { Cassify::Models::TicketGrantingTicket.validate(nil) }.should raise_error
  end
end
