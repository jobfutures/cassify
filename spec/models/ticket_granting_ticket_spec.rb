require 'spec_helper'

describe Cassify::TicketGrantingTicket, "#generate!" do
  it "should return a ticket object" do
    ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "http://localhost:3000", :roles => ["owner", "user"])
    ticket_granting_ticket.to_s.should match /^TGC-/
  end
end

describe Cassify::TicketGrantingTicket, "#validate" do
  it "should return a ticket object if ticket is valid" do
    ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "http://localhost:3000")
    Cassify::TicketGrantingTicket.validate(ticket.ticket).class.should == Cassify::TicketGrantingTicket
  end
  
  it "should raise exception if ticket nil" do
    lambda { Cassify::TicketGrantingTicket.validate(nil) }.should raise_error
  end
end
