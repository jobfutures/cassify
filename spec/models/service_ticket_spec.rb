require 'spec_helper'

describe Cassify::ServiceTicket do
  let(:ticket_granting_ticket) { ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "localhost") }
  let(:service_ticket) do
    Cassify::ServiceTicket.create! do |c|
      c.granted_by_tgt  = ticket_granting_ticket
      c.service         = "http://localhost:3000"
      c.client_hostname = "localhost"
      c.username        = ticket_granting_ticket.username
    end
  end
  
  it "should be consumable" do
    service_ticket.should_not be_consumed
    service_ticket.consume!
    service_ticket.should be_consumed
  end

  it "should be expirable" do
    service_ticket.update_attribute(:created_on, Time.now - 2.days)
    service_ticket.should be_expired
  end

  it "should have to_s method" do
    service_ticket.to_s.should == service_ticket.ticket
  end
end
