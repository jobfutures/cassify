require 'spec_helper'

describe Cassify::Models::TicketGrantingTicket do
  it "should return a ticket object" do
    ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "http://localhost:3000", :roles => ["owner", "user"])
    ticket_granting_ticket.to_s.should match /^TGC-/
  end

  it "should raise exception if ticket nil" do
    lambda { Cassify::Models::TicketGrantingTicket.validate(nil) }.should raise_error
  end
end
